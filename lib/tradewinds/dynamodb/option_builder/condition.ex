defmodule Tradewinds.Dynamo.OptionBuilder.ConditionExpression do
  @moduledoc """
  This module is used to construct condition expressions.
"""

  alias Tradewinds.Crypto.KeyAlias
  alias Tradewinds.Helpers.Maps

  @spec add_condition(list(binary), binary) :: list(binary)
  def add_condition(condition_list, condition) do
    [condition | condition_list]
  end

  @spec add_existence_condition(list(binary), binary) :: list(binary)
  def add_existence_condition(condition_list, attribute) do
    add_condition(condition_list, [:attribute_exists, attribute])
  end

  @spec add_non_existence_condition(list(binary), atom | binary) :: list(binary)
  def add_non_existence_condition(condition_list, attribute) when is_atom(attribute) do
    add_condition(condition_list, Atom.to_string(attribute))
  end

  def add_non_existence_condition(condition_list, attribute) do
    add_condition(condition_list, [:attribute_not_exists, attribute])
  end

  @spec alias_conditions(list(), map()) :: {list(), map()}
  def alias_conditions(condition_list, alias_map \\ %{}) do
    condition_list
    |> Enum.reduce({[], alias_map}, fn [condition, attr], {rolling_list, aliases} ->
      case Map.has_key?(aliases, attr) do
        true -> aliases
        false -> Map.put(aliases, attr, "##{KeyAlias.generate()}")
      end
      |> (fn aliases ->
            {List.insert_at(rolling_list, 0, [condition, Map.get(aliases, attr)]), aliases}
          end).()
    end)
  end

  @spec compile(list(binary), map()) :: binary
  def compile(condition_list, alias_map \\ %{}) do
    condition_list
    |> Enum.reject(fn value -> value == :nil end)
    |> alias_conditions(alias_map)
    |> (fn {conditions, aliases} ->
          conditions
          |> Enum.map(&compile_condition/1)
          |> Enum.join(" AND ")
          |> (fn cond_str -> {cond_str, aliases} end).()
        end).()
  end

  @spec compile_condition(list()) :: binary()
  def compile_condition(condition)
  def compile_condition([:attribute_not_exists, attribute]) do
    "attribute_not_exists(#{attribute})"
  end

  def compile_condition([:attribute_exists, attribute]) do
    "attribute_exists(#{attribute})"
  end

  @spec init :: list
  def init, do: []
end