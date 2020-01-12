defmodule Mix.Tasks.Auth0.Client.Create do
  @moduledoc """
  This module is home to the mix task used to create Auth0 clients
"""
  use Mix.Task
  import Mix.Tasks.Auth0.Client.Common
  alias Auth0Ex.Management.Client

  @doc """
    Create a Auth0 client.

    This task relies on the the following environment variables being set:
    AUTH0_MANAGEMENT_TOKEN
    AUTH0_DOMAIN
    This information can be found in the Auth0 account.

    This task should be used as follows:
    `mix Auth0.Client.create name=something other=args as=needed`
    The pairs are spit into key-value pairs in a map and added to the content defined in
    tradewinds/config/auth0_client.json
    Anything specified on the command line will overwrite the config in the JSON file.
  """
  @doc since: "0.1.0"
  @shortdoc "Create a new client in Auth0"
  def run(argv) do
    Application.ensure_all_started(:hackney)
    Application.ensure_all_started(:auth0_ex)
    case File.read(Path.expand("./config/auth0_client.json")) do
      {:error, message, code} ->
        IO.puts("#{code} - #{message}")
        exit({:error, 1})
      {:ok, content} -> Poison.decode!(content)
    end
    |> Map.merge(args_to_map(argv))
    |> Client.create
    |> case do
         {:error, error_string, _} ->
           %{"statusCode" => code, "error" => error, "message" => message} = Poison.decode!(error_string)
           IO.puts("#{code}:#{error} - #{message}")
         {:ok, result_map} ->
           %{"name" => name, "client_id" => client, "client_secret" => secret} = result_map
           Poison.encode!(%{name: name, client_id: client, client_secret: secret}) |> IO.puts
       end
  end
end
