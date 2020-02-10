defmodule Mix.Tasks.Dynamo.List do
  @moduledoc """
    This module is home to mix task used to list dynamoDB tables

    The functionality of this task is largely driven by the ExAWS config
  """

  use Mix.Task
  alias Tradewinds.Dynamo.Table

  @shortdoc "Lists existing DynamoDB tables"
  def run(_) do
    Application.ensure_all_started(:hackney)
    IO.puts("Tables:")
    Table.list()
    |> Enum.each(fn table -> IO.puts(table) end)
  end
end
