defmodule Tradewinds.Dynamo.QueryBuilder do
  @moduledoc """
  This module is used to build queries for the Dynamo query function.

  It includes helpers for constructing various expressions used in a query.
"""

  @type exclusive_start_key_vals :: [{atom, binary}] | %{optional(atom) => binary}
  @type return_consumed_capacity_vals :: :none | :total | :indexes
  @type expression_attribute_names_vals :: %{optional(binary) => binary}
  @type expression_attribute_values_vals :: [{atom, binary}] | %{optional(atom) => binary}

  @spec add_index(keyword, binary) :: keyword
  def add_index(query, index_name), do: Keyword.put(query, :index_name, index_name)

  @spec add_key_cond_exp(keyword, binary) :: keyword
  def add_key_cond_exp(query, expression), do: Keyword.put(query, :key_condition_expression, expression)

  @spec add_filter_exp(keyword, binary) :: keyword
  def add_filter_exp(query, expression), do: Keyword.put(query, :filter_expression, expression)

  @spec add_projection_exp(keyword, binary) :: keyword
  def add_projection_exp(query, expression), do: Keyword.put(query, :projection_expression, expression)

  @spec add_limit(keyword, integer) :: keyword
  def add_limit(query, limit), do: Keyword.put(query, :limit, limit)

  @spec add_start_key(keyword, exclusive_start_key_vals) :: keyword
  def add_start_key(query, start_key), do: Keyword.put(query, :exclusive_start_key, start_key)

  @spec consistent_read(keyword, boolean) :: keyword
  def consistent_read(query, read), do: Keyword.put(query, :consistent_read, read)

  @spec return_consumed_cap(keyword, boolean) :: keyword
  def return_consumed_cap(query, cap), do: Keyword.put(query, :return_consumed_capacity, cap)

  @spec scan_idx_forward(keyword, boolean) :: keyword
  def scan_idx_forward(query, scan), do: Keyword.put(query, :scan_index_forward, scan)

  @spec add_exp_attr_names(keyword, expression_attribute_names_vals) :: keyword
  def add_exp_attr_names(query, attr_names), do: Keyword.put(query, :expression_attribute_names, attr_names)

  @spec add_exp_attr_vals(keyword, expression_attribute_values_vals) :: keyword
  def add_exp_attr_vals(query, attr_vals), do: Keyword.put(query, :expression_attribute_values, attr_vals)

  @spec init :: keyword
  def init, do: Keyword.new()
end
