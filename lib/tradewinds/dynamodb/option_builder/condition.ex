defmodule Tradewinds.Dynamo.OptionBuilder.ConditionExpression do
  @moduledoc """
  This module is used to construct condition expressions.
"""

  @spec add_condition(list(binary), binary) :: list(binary)
  def add_condition(condition_list, condition) do
    [condition | condition_list]
  end

  @spec add_existence_condition(list(binary), binary) :: list(binary)
  def add_existence_condition(condition_list, attribute) do
    add_condition(condition_list, "attribute_exists(#{attribute})")
  end

  @spec add_non_existence_condition(list(binary), binary) :: list(binary)
  def add_non_existence_condition(condition_list, attribute) do
    add_condition(condition_list, "attribute_not_exists(#{attribute})")
  end

  @spec compile(list(binary)) :: binary
  def compile(condition_list) do
    condition_list
    |> Enum.reject(fn value -> value == :nil end)
    |> Enum.join(" AND ")
  end

  @spec init :: list
  def init, do: []
end