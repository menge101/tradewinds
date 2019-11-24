defmodule Mix.Tasks.Auth0.Client.Update do
  use Mix.Task
  import Mix.Tasks.Auth0.Client.Common


  @doc """
    Update a Auth0 client.

    This task relies on the the following environment variables being set:
    AUTH0_MANAGEMENT_TOKEN
    AUTH0_DOMAIN
    This information can be found in the Auth0 account.

    This task should be used as follows:
    `mix Auth0.Client.update client_id name=something other=args as=needed`
    The pairs are spit into key-value pairs in a map and then applied to the existing client.
  """

  @shortdoc "Create a new client in Auth0"
  def run(argv) do
    Application.ensure_all_started(:hackney)
    Application.ensure_all_started(:auth0_ex)
    [client_id | args] = argv
    Auth0Ex.Management.Client.update(client_id, args_to_map(args))
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
