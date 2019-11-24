defmodule Mix.Tasks.Auth0.Client.Common do
  def args_to_map(arg_list) do
    Enum.map(arg_list, fn arg -> String.split(arg, "=", parts: 2) end)
    |> Enum.map(fn pair ->
      [key | [ value | _]] = pair
      %{key => convert_booleans(value)}
    end)
    |> Enum.reduce(%{}, fn x, acc -> Map.merge(acc, x) end)
  end

  def convert_booleans(string_value) do
    case string_value do
      "true" -> true
      "false" -> false
      x -> x
    end
  end
end