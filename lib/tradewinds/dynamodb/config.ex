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