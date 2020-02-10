defmodule Tradewinds.Dynamo.Repo do
  import Tradewinds.Dynamo.Repo.Bulk
  # import Math

  alias ExAws.Dynamo
  alias ExAws.Dynamo.Decoder
  alias Tradewinds.Dynamo.Config
  alias Tradewinds.Dynamo.Exceptions.TableDoesNotExist
  alias Tradewinds.Dynamo.OptionBuilder
  alias Tradewinds.Dynamo.OptionBuilder.ConditionExpression

  @moduledoc """
  This module is home to all common functionality for interacting with DynamoDB
"""

  @type primary_key :: [{atom(), binary()}] | %{optional(atom()) => binary()}
  @type expression_attribute_names_vals() :: %{optional(binary()) => binary()}
  @type return_consumed_capacity_vals() :: :none | :total | :indexes
  @type expression_attribute_values_vals() ::
          [{atom(), ExAws.Dynamo.Encodable.t()}] | %{optional(atom()) => ExAws.Dynamo.Encodable.t()}
  @type return_item_collection_metrics_vals() :: :size | :none
  @type return_values_vals() :: :none | :all_old | :updated_old | :all_new | :updated_new
  @type exclusive_start_key_vals() :: [{atom(), binary()}] | %{optional(atom()) => binary()}
  @type select_vals() :: :all_attributes | :all_projected_attributes | :specific_attributes | :count
  @type get_item_opts :: [
                             consistent_read: boolean(),
                             expression_attribute_names: expression_attribute_names_vals(),
                             projection_expression: binary(),
                             return_consumed_capacity: return_consumed_capacity_vals()
                           ]
  @type put_item_opts :: [
                             condition_expression: binary(),
                             expression_attribute_names: expression_attribute_names_vals(),
                             expression_attribute_values: expression_attribute_values_vals(),
                             return_consumed_capacity: return_consumed_capacity_vals(),
                             return_item_collection_metrics: return_item_collection_metrics_vals(),
                             return_values: return_values_vals()
                           ]
  @type query_opts :: [
                        consistent_read: boolean(),
                        exclusive_start_key: exclusive_start_key_vals(),
                        expression_attribute_names: expression_attribute_names_vals(),
                        expression_attribute_values: expression_attribute_values_vals(),
                        filter_expression: binary(),
                        index_name: binary(),
                        key_condition_expression: binary(),
                        limit: pos_integer(),
                        projection_expression: binary(),
                        return_consumed_capacity: return_consumed_capacity_vals(),
                        scan_index_forward: boolean(),
                        select: select_vals()
                      ]


  @doc """
  The create/1 function is a special case of the put function where it is hard coded to fail if a record with the given primary key already exists
"""
  @spec create(map(), put_item_opts) :: map()
  def create(record, opts \\ []) do
    Config.keys()
    |> Enum.reduce(ConditionExpression.init(), fn key, acc ->
        ConditionExpression.add_non_existence_condition(acc, key)
       end)
    |> ConditionExpression.compile()
    |> (fn conditions -> OptionBuilder.add_put_option(opts, :condition_expression, conditions) end).()
    |> (fn opts -> put(record, opts) end).()
  end

  @doc """
  The delete/1 function exists for the obvious purpose of deleting a record
"""
  @spec delete(primary_key) :: map()
  def delete(primary_key) do
    Config.table_name()
    |> Dynamo.delete_item(primary_key)
    |> ExAws.request
  end

  @doc """
  The get/2 function exists to facilitate reading a single record from the DynamoDB table
"""
  @spec get(primary_key, get_item_opts) :: map()
  def get(primary_key, opts \\ []) do
    Config.table_name()
    |> Dynamo.get_item(primary_key, opts)
    |> ExAws.request
    |> case do
         {:error, message} -> infer_and_raise_exception(message)
         {:ok, %{"Item" => body}} -> distill(body)
         {:ok, body} -> body
       end
  end

  @doc """
  The put/2 function exists to facilitate putting a record to the DynamoDB table with additional metadata
"""
  @spec put(map(), put_item_opts) :: map()
  def put(record, opts \\ []) do
    Config.table_name()
    |> Dynamo.put_item(add_timestamp(record), opts)
    |> ExAws.request
    |> case do
         {:error, message} -> infer_and_raise_exception(message)
         {:ok, %{}} -> record
       end
  end

  @spec query(query_opts) :: map()
  def query(query_opts) do
    Config.table_name()
    |> Dynamo.query(query_opts)
    |> ExAws.request
  end

  @spec update(map(), put_item_opts) :: map()
  def update(record, opts \\ []) do
    Config.keys()
    |> Enum.reduce(ConditionExpression.init(), fn key, acc ->
      ConditionExpression.add_existence_condition(acc, key)
    end)
    |> ConditionExpression.compile()
    |> (fn conditions -> OptionBuilder.add_put_option(opts, :condition_expression, conditions) end).()
    |> (fn opts -> put(record, opts) end).()
  end

  defp add_condition(opts, value) do
    Keyword.get(opts, :condition_expression, nil)
    |> (fn value -> [value] end).()
    |> (fn current -> [value | current] end).()
    |> Enum.reject(fn value -> value == :nil end)
    |> Enum.join(" AND ")
    |> (fn condition, kw_collection -> Keyword.put(kw_collection, :condition_expression, condition) end).(opts)
  end

  @spec add_timestamp(map()) :: map()
  defp add_timestamp(record) do
    record
    |> Map.put(:updated_at, DateTime.now!("Etc/UTC") |> DateTime.to_iso8601())
  end

  @spec distill(list(map())) :: map()
  defp distill(body) do
    Enum.map(body, fn {field, coded} -> %{field => Decoder.decode(coded)} end)
    |> Enum.reduce(%{}, fn map, acc -> Map.merge(acc, map) end)
  end

  @spec infer_and_raise_exception(binary()) :: nil
  def infer_and_raise_exception(msg) do
    msg
    |> case do
         {"ResourceNotFoundException", "Cannot do operations on a non-existent table"} -> raise TableDoesNotExist
         {exception, message} -> raise ArgumentError, message: "#{exception} - #{message}"
       end
  end
end
