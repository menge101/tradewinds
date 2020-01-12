defmodule Mix.Tasks.Auth0.Client.Delete do
  @moduledoc """
    This module is home to the mix task used to delete Auth0 clients
  """
  use Mix.Task
  alias Auth0Ex.Management.Client

  @doc """
  Deletes an Auth0 client
"""
  @shortdoc "Delete Auth0 clients"
  @doc since: "0.1.0"
  def run(argv) do
    Application.ensure_all_started(:hackney)
    Application.ensure_all_started(:auth0_ex)
    Enum.map(argv, fn client_id ->
      case Client.delete(client_id) do
        :ok -> "#{client_id} - successfully deleted"
        _ -> "#{client_id} - unknown state"
      end
    end)
    |> Enum.join("\n")
    |> IO.puts
  end
end
