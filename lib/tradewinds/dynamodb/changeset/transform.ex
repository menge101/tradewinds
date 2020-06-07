defmodule Tradewinds.Dynamo.Changeset.Transform do
  @moduledoc """
  This module is home to functions for transforming a change set into an actionable data collection.
"""

  alias Tradewinds.Dynamo.Changeset
  alias Tradewinds.Dynamo.Config
  alias Tradewinds.Dynamo.OptionBuilder
  alias Tradewinds.Dynamo.OptionBuilder.ConditionExpression
  alias Tradewinds.Dynamo.Record
  alias Tradewinds.Helpers.Maps

  def to_record(%Changeset{} = changeset) do
    constraints = find_constraints(changeset)
    |> build_conditions_from_constraints()

    data = changeset
    |> Map.get(:changes)
    |> Maps.stringify_keys()
    |> Enum.filter(fn {k, v} -> !is_nil(v) end)
    |> Enum.reduce(%{}, fn {k, v}, acc -> Map.put(acc, k, v) end)

    %Record{constraints: constraints, data: data}
  end

  def build_conditions_from_constraints(constraints) do
    Enum.reduce(constraints, ConditionExpression.init(),
      fn constraint, acc -> ConditionExpression.add_existence_condition(acc, constraint) end)
  end

  def find_constraints(%Changeset{} = changeset) do
    Enum.filter(Maps.stringify_keys(Map.get(changeset, :original)),
      fn {k, v} -> Maps.stringify_keys(Map.get(changeset, :changes))[k] == v end)
    |> Enum.filter(fn {_, v} -> !is_nil(v) end)
    |> Keyword.keys()
  end
end
