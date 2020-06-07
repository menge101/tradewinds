defmodule Tradewinds.Helpers.Structs do
  @moduledoc """
  This module holds helper function for working with Structs, generically
  """

  @doc """
  This function returns the keys of the Struct using the Map.keys function,
  but also removed the special :__struct__ key.
"""
  @spec keys(struct()) :: list(:atom | :binary)
  def keys(%_{} = struct) do
    Map.keys(struct)
    |> List.delete(:__struct__)
  end
end

