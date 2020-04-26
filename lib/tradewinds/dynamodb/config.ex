defmodule Tradewinds.Dynamo.Config do
  @moduledoc """
    This module is used to deal with the table definition set in the config
  """

  @type table_def :: %{:table => %{
    name: binary(),
    key_schema: primary_key_schema(),
    global_indexes: [Map.t()],
    local_indexes: [Map.t()],
    rcu: integer(),
    wcu: integer(),
    billing_type: :pay_per_request | :provisioned
  }}

  @type primary_key_schema :: [key_schema()]
  @type key_schema :: %{
                        attribute_name: binary(),
                        attribute_type: binary(),
                        key_type: binary()
                      }
  @spec key(binary(), table_def()) :: binary()
  def key(key_type, table_def)
  def key(key_type, table_def \\ Application.fetch_env!(:tradewinds, :dynamodb)[:table]) when key_type in ["HASH", "RANGE"] do
    table_def
    |> Map.get(:key_schema)
    |> Enum.filter(fn key_def -> key_def[:key_type] == key_type end)
    |> case do
         [] -> nil
         [key_def] -> Map.get(key_def, :attribute_name)
       end
  end

  def key(_, _) do
    raise ArgumentError, "key_type must be either RANGE or HASH"
  end

  @spec keys(table_def()) :: [binary()]
  def keys(table_def \\ Application.fetch_env!(:tradewinds, :dynamodb)[:table]) do
    table_def
    |> Map.get(:key_schema)
    |> Enum.map(fn key_set -> key_set[:attribute_name] end)
  end

  @spec table_name(table_def()) :: binary()
  def table_name(table_def \\ Application.fetch_env!(:tradewinds, :dynamodb)[:table]) do
    table_def[:name]
  end
end