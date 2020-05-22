defmodule Tradewinds.Dynamo.Repo do

  alias ExAws.Dynamo
  alias ExAws.Dynamo.Decoder
  alias Tradewinds.Dynamo.Changeset
  alias Tradewinds.Dynamo.Changeset.Transform
  alias Tradewinds.Dynamo.Config
  alias Tradewinds.Dynamo.Exceptions.TableDoesNotExist
  alias Tradewinds.Dynamo.OptionBuilder
  alias Tradewinds.Dynamo.OptionBuilder.ConditionExpression
  alias Tradewinds.Dynamo.Record
  alias Tradewinds.Dynamo.Repo.Bulk
  alias Tradewinds.Dynamo.Repo.Put
  alias Tradewinds.Helpers.Maps

  @moduledoc """
  This module is home to all common functionality for interacting with DynamoDB
"""

  @type primary_key :: [{atom(), binary()}] | %{optional(atom()) => binary()}
  @type exclusive_start_key_vals() :: [{atom(), binary()}] | %{optional(atom()) => binary()}
  @type expression_attribute_names_vals() :: %{optional(binary()) => binary()}
  @type expression_attribute_values_vals() ::
          [{atom(), ExAws.Dynamo.Encodable.t()}] | %{optional(atom()) => ExAws.Dynamo.Encodable.t()}
  @type return_consumed_capacity_vals() :: :none | :total | :indexes
  @type return_values_vals() :: :none | :all_old | :updated_old | :all_new | :updated_new
  @type select_vals() :: :all_attributes | :all_projected_attributes | :specific_attributes | :count
  @type get_item_opts :: [
                             consistent_read: boolean(),
                             expression_attribute_names: expression_attribute_names_vals(),
                             projection_expression: binary(),
                             return_consumed_capacity: return_consumed_capacity_vals()
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


  @spec create(map() | %Changeset{} | %Record{}) :: map()
  defdelegate create(record), to: Put

  @spec create(map() | %Changeset{} | %Record{}, Put.put_item_opts) :: map()
  defdelegate create(record, opts), to: Put

  @spec update(map() | %Changeset{} | %Record{}) :: map()
  defdelegate update(record), to: Put

  @spec update(map() | %Changeset{} | %Record{}, Put.put_item_opts) :: map()
  defdelegate update(record, opts), to: Put

  @spec write_collection(Bulk.write_collection) :: bool
  defdelegate write_collection(collection), to: Bulk

  @spec write_collection(Bulk.write_collection, Bulk.write_collection_opts) :: bool
  defdelegate write_collection(collection, opts), to: Bulk



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

  @spec query(query_opts) :: map()
  def query(query_opts) do
    Config.table_name()
    |> Dynamo.query(query_opts)
    |> ExAws.request
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

  def to_struct(attrs, kind) do
    struct = struct(kind)
    Map.to_list(struct)
    |> Enum.reduce(struct, fn {k, _}, acc ->
         cond do
           Map.has_key?(attrs, k) ->
             Map.fetch(attrs, k)
           Map.has_key?(attrs, Atom.to_string(k)) ->
             Map.fetch(attrs, Atom.to_string(k))
           true -> :error
         end
         |> case do
              {:ok, v} -> %{acc | k => Maps.atomize_map_keys(v)}
              :error -> acc
            end
      end)
  end
end
