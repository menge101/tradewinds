defmodule Tradewinds.Dynamo.Table do
  @moduledoc """
  This module holds functionality relate to Dynamo tables
"""

  alias ExAws.Dynamo

  @type http_status :: pos_integer
  @type success_content :: %{body: binary, headers: [{binary, binary}]}
  @type success_t :: {:ok, success_content}
  @type error_t :: {:error, {:http_error, http_status, binary}}
  @type response_t :: success_t | error_t

  @doc """
  This function is used to create a Dynamo table
"""
  @spec create(map()) :: response_t
  def create(%{"name" => name, "key_schema" => key_schema, "global_indexes" => gi, "local_indexes" => li,
    "rcu" => rcu, "wcu" => wcu, "billing_type" => billing}) do
    create(name, key_schema, gi, li, rcu, wcu, String.to_atom(billing))
  end

  @spec create(map()) :: response_t
  def create(%{name: name, key_schema: key_schema, global_indexes: gi, local_indexes: li, rcu: rcu, wcu: wcu,
    billing_type: billing}) do
    create(name, key_schema, gi, li, rcu, wcu, billing)
  end

  @spec create(binary, map(), list(), list(), integer(), integer(), atom()) :: response_t
  def create(name, key_schema, global_indexes, local_indexes, rcu, wcu, billing_type) do
    Dynamo.create_table(name,
      Enum.map(key_schema, &build_key_schema/1),
      Enum.reduce(key_schema, %{}, &build_key_def/2),
      rcu, wcu, global_indexes, local_indexes, billing_type)
    |> ExAws.request
  end

  @spec delete(binary) :: response_t
  def delete(table_name) do
    Dynamo.delete_table(table_name)
    |> ExAws.request
  end

  @doc """
    The describe/1 function exists to describe a table
  """
  @spec describe(binary) :: response_t
  def describe(table_name) do
    Dynamo.describe_table(table_name)
    |> ExAws.request
  end


  @spec list :: list()
  def list do
    Dynamo.list_tables()
    |> ExAws.request!
    |> Map.get("TableNames")
  end

  @spec scan(binary) :: map()
  def scan(table_name) do
    Dynamo.scan(table_name)
    |> ExAws.request!
  end

  @spec build_key_def(map(), map()) :: map()
  defp build_key_def(%{"attribute_name" => attr_name, "attribute_type" => attr_type}, acc)
       when is_binary(attr_name) and is_binary(attr_type) do
    Map.merge(acc, %{String.to_atom(attr_name) => String.to_atom(attr_type)})
  end

  defp build_key_def(%{attribute_name: attr_name, attribute_type: attr_type}, acc)
       when is_binary(attr_name) and is_binary(attr_type) do
    Map.merge(acc, %{String.to_atom(attr_name) => String.to_atom(attr_type)})
  end

  @spec build_key_schema(map()) :: [key: binary]
  defp build_key_schema(%{"attribute_name" => attr_name, "key_type" => key_type}) do
    {attr_name, key_type}
  end

  defp build_key_schema(%{attribute_name: attr_name, key_type: key_type}) do
    {attr_name, key_type}
  end
end
