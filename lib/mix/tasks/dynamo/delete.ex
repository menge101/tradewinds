defmodule Mix.Tasks.Dynamo.Delete do
  @moduledoc """
    This module is home to mix task used to delete dynamoDB tables

    The functionality of this task is largely driven by the ExAWS config
  """

  use Mix.Task
  alias Tradewinds.Dynamo.Table

  @shortdoc "Delete a DynamoDB table"
  def run(argv) do
    ensure_not_prod()
    Application.ensure_all_started(:hackney)
    table_name = List.first(argv)
    table_name
    |> Table.delete()
    |> case do
         {:error, {"ResourceNotFoundException", "Cannot do operations on a non-existent table"}} ->
           "Table '#{table_name}' not found"
           {:ok, %{"TableDescription" => %{"TableName" => name}}} -> "Table '#{name}' deleted"
       end
    |> IO.puts
  end

  defp ensure_not_prod do
    if Mix.env == :prod do
      Mix.shell().error("This task may not be run in production")
      exit({:error, 1})
    end
  end
end
