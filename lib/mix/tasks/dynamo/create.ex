defmodule Mix.Tasks.Dynamo.Create do
  @moduledoc """
  This module is home to mix task used to create dynamoDB tables
"""

  use Mix.Task
  alias ExAws.Dynamo
  alias Tradewinds.Dynamo.Table

  @shortdoc "Create a DynamoDB table"
  def run(_) do
    Application.ensure_all_started(:hackney)
    get_table_schemas()
    |> Table.create()
    |> case do
         {:ok, %{"TableDescription" => %{"TableName" => name}}} ->
           "Table '#{name}' created"
         {:error, {"ResourceInUseException", "Cannot create preexisting table"}} ->
           "Table already exists"
       end
    |> IO.puts
  end

  def get_table_schemas do
    Application.fetch_env!(:tradewinds, :dynamodb)[:table]
  end

  defp error_exit(code, message) do
      IO.puts(message)
      exit({:error, code})
    end
end
