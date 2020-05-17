defmodule Tradewinds.Helpers.Maps do
  @moduledoc """
  This module is home to helper functionality for dealing with maps
"""


  def atomize_map_key(key) when is_binary(key), do: String.to_existing_atom(key)
  def atomize_map_key(atom) when is_atom(atom), do: atom
  def atomize_map_key(any), do: raise(ArgumentError, "Cannot atomize non-string keys")

  @doc """
    This function can be passed anything, if it passed a map, it will turn all the keys within that map to atoms.

    It does this recursively through the data structure passed in.
  """
  @spec atomize_map_keys(Any) :: Any
  def atomize_map_keys(map) when is_map(map) do
    Map.new(map, fn {key, value} -> {atomize_map_key(key), atomize_map_keys(value)} end)
  end
  def atomize_map_keys(list) when is_list(list), do: Enum.map(list, &atomize_map_keys/1)
  def atomize_map_keys(any), do: any

  @spec invert_map(map()) :: map()
  def invert_map(map) when is_map(map) do
    Map.new(map, fn {key, val} -> {val, key} end)
  end

  @spec stringify_key(atom | binary) :: binary
  def stringify_key(key) when is_atom(key), do: Atom.to_string(key)
  def stringify_key(key), do: key

  @spec stringify_keys(map()) :: map()
  def stringify_keys(map) do
    Map.new(map, fn {key, value} -> {stringify_key(key), value} end)
  end
end
