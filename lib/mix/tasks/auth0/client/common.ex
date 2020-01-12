defmodule Mix.Tasks.Auth0.Client.Common do
  @moduledoc """
  This module holds common functions for all of the Auth0 Client modules
"""
  @doc """
  This function is intended to take the argv from a mix task and convert it to a map for easier use.

  Returns `%{}`

  ## Examples
    iex> Mix.Tasks.Auth0.Client.Common.args_to_map(["a=aye", "b=bee", "c=sea", "d=true"])
    %{"a" => "aye", "b" => "bee", "c" => "sea", "d" => true}
"""

  @doc since: "0.1.0"
  def args_to_map(arg_list) do
    Enum.map(arg_list, fn arg -> String.split(arg, "=", parts: 2) end)
    |> Enum.map(fn pair ->
      [key | [value | _]] = pair
      %{key => convert_booleans(value)}
    end)
    |> Enum.reduce(%{}, fn x, acc -> Map.merge(acc, x) end)
  end

  @doc """
  Function to change 'true' and 'false' strings to boolean values.

  Returns `true`, `false`

  ## Examples
    iex> Mix.Tasks.Auth0.Client.Common.convert_booleans("true")
    true

    iex> Mix.Tasks.Auth0.Client.Common.convert_booleans("false")
    false

    iex> Mix.Tasks.Auth0.Client.Common.convert_booleans("boom")
    "boom"
"""
  @doc since: "0.1.0"
  def convert_booleans(string_value) do
    case string_value do
      "true" -> true
      "false" -> false
      x -> x
    end
  end
end
