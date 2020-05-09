defmodule Tradewinds.Dynamo.Changeset do
  @moduledoc """
  DynamoDB changeset struct.
"""

  defstruct [:changes, :errors, :original]

  @doc """
    The cast/3 function takes a map, and a list of keys and applies them to a provided struct
  """
  @spec cast(struct(), map(), list()) :: struct()
  def cast(struct, map, keys) do
    Enum.reduce(keys, %Tradewinds.Dynamo.Changeset{errors: [], changes: %{}, original: Map.from_struct(struct)},
      fn key, acc ->
        cond do
          Map.has_key?(map, key) ->
            Map.get(acc, :changes)
            |> Map.put(key, Map.get(map, key))
            |> (fn data -> Map.put(acc, :changes, data) end).()
          Map.has_key?(struct, key) ->
            Map.get(acc, :changes)
            |> Map.put(key, Map.get(struct, key))
            |> (fn data -> Map.put(acc, :changes, data) end).()
          true ->
            Map.get(acc, :errors)
            |> (fn error_list -> ["Key #{key} not found." | error_list] end).()
            |> (fn errors -> Map.put(acc, :errors, errors) end).()
        end
      end)
  end

  @doc """
    The join_errors function is a mechanism for fast joining of errors to the existing array
  """
  @spec join_errors(list(), list()) :: list()
  def join_errors([], old_errors), do: old_errors
  def join_errors(new_errors, []), do: new_errors
  def join_errors(new_errors, old_errors), do: [new_errors | old_errors]
end
