defmodule Mix.Tasks.Dynamo.Describe do
  @moduledoc """
  This module is home to the mix task used to describe DynamoDB tables

  The functionality of this task is largely driven by the ExAWS config.
  For example, for MIX_ENV dev (the default) and test this task expects a local running
  DynamoDB instance.
"""
  use Mix.Task
  alias Tradewinds.Dynamo.Table

  @shortdoc "Describes a DynamoDB table"
  def run(argv) do
    Application.ensure_all_started(:hackney)
    List.first(argv)
    |> (fn table ->
          IO.puts "#{table}:"
          table
        end).()
    |> Table.describe
    |> IO.inspect
  end
end