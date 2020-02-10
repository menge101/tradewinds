defmodule Tradewinds.Dynamo.OptionBuilder do
  @moduledoc """
  This module is used to construct options arguments for Dynamo calls.

  It contains helper functions for various expressions used in an option map.

  Functionality is developed here as needed.
"""

  @type expression_attribute_names_vals() :: %{optional(binary()) => binary()}
  @type expression_attribute_values_vals() ::
          [{atom(), ExAws.Dynamo.Encodable.t()}] | %{optional(atom()) => ExAws.Dynamo.Encodable.t()}
  @type return_consumed_capacity_vals() :: :none | :total | :indexes
  @type return_item_collection_metrics_vals() :: :size | :none
  @type return_values_vals() :: :none | :all_old | :updated_old | :all_new | :updated_new
  @type put_item_opts :: [
                           condition_expression: binary(),
                           expression_attribute_names: expression_attribute_names_vals(),
                           expression_attribute_values: expression_attribute_values_vals(),
                           return_consumed_capacity: return_consumed_capacity_vals(),
                           return_item_collection_metrics: return_item_collection_metrics_vals(),
                           return_values: return_values_vals()
                         ]
  @type put_item_opt_keys() :: :condition_expression | :expression_attribute_names | :expression_attribute_values | :return_consumed_capacity | :return_item_collection_metrics

  @put_options [:condition_expression, :expression_attribute_names, :expression_attribute_values,
    :return_consumed_capacity, :return_item_collection_metrics]

  @spec add_option(keyword, any, any) :: keyword
  defp add_option(opts, key, value) do
    Keyword.put(opts, key, value)
  end

  @spec add_put_option(keyword, put_item_opt_keys(), put_item_opts()) :: put_item_opts()
  def add_put_option(opts, key, value) when key in @put_options do
    add_option(opts, key, value)
  end

  def add_put_option(_, key, _) when key not in @put_options do
    valid_option_string = Enum.join(@put_options, ", ")
    raise(ArgumentError, message: "#{key} is not a valid put option, must be one of #{valid_option_string}")
  end

  @spec init :: keyword
  def init, do: Keyword.new()
end