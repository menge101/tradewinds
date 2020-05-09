defmodule Tradewinds.Dynamo.Changeset.Transform do
  @moduledoc """
  This module is home to functions for transforming a change set into an actionable data collection.
"""

  alias Tradewinds.Dynamo.Changeset
  alias Tradewinds.Dynamo.Config
  alias Tradewinds.Dynamo.OptionBuilder
  alias Tradewinds.Dynamo.OptionBuilder.ConditionExpression
  alias Tradewinds.Dynamo.Record

  def to_record(%Changeset{} = changeset) do
    find_constraints(changeset)
    |> build_conditions_from_constraints()
    |> (fn constraints ->
          %Record{constraints: constraints, data: Map.get(changeset, :changes)}
        end).()
  end

  def build_conditions_from_constraints(constraints) do
    Enum.reduce(constraints, ConditionExpression.init(),
      fn constraint, acc -> ConditionExpression.add_existence_condition(acc, constraint) end)
  end

  def find_constraints(%Changeset{} = changeset) do
    Enum.filter(Map.get(changeset, :original), fn {k, v} -> Map.get(changeset, :changes)[k] == v end)
    |> Keyword.keys()
  end
end
