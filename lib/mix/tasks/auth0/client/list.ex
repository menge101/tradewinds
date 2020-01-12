defmodule Mix.Tasks.Auth0.Client.List do
  @moduledoc """
    This module is home to the mix task used to list Auth0 clients
  """
  use Mix.Task
  alias Auth0Ex.Management.Client

  @doc """
  Lists all existing Auth0 clients
"""
  @doc since: "0.1.0"
  @shortdoc "List all clients in Auth0"
  def run(argv) do
    Application.ensure_all_started(:hackney)
    Application.ensure_all_started(:auth0_ex)
    case argv do
      [] -> Client.all()
      non_empty ->
        Client.all(%{fields: Enum.join(non_empty, ",")})
    end
    |> case do
         # credo:disable-for-lines:2 Credo.Check.Warning.IoInspect
         {:ok, results} -> IO.inspect results
         anything_else -> IO.inspect anything_else
       end
  end
end
