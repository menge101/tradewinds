defmodule Mix.Tasks.Dynamo.Scan do
  @moduledoc """
  This module is home to the mix task used to scan a DynamoDB table.

  This should not be used against a production db.

  Like other tasks, the config drives a lot.
"""
  use Mix.Task
  alias Tradewinds.Dynamo.Table

  @shortdoc "Scans a DynamoDB table and displays contents"
  def run(argv) do
    ensure_not_prod()
    Application.ensure_all_started(:hackney)
    List.first(argv)
    |> (fn table ->
          IO.puts "Scanning #{table}:"
          table
        end).()
    |> Table.scan()
    |> IO.inspect
  end

  defp ensure_not_prod do
    if Mix.env == :prod do
      Mix.shell().error("This task may not be run in production")
      exit({:error, 1})
    end
  end
end