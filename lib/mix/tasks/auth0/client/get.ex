defmodule Mix.Tasks.Auth0.Client.Get do
  use Mix.Task


  @doc """
    Get a Auth0 client details.

    This task relies on the the following environment variables being set:
    AUTH0_MANAGEMENT_TOKEN
    AUTH0_DOMAIN
    This information can be found in the Auth0 account.

    This task should be used as follows:
    `mix Auth0.Client.get client_id`
  """

  @shortdoc "Get client details from Auth0"
  def run(argv) do
    Application.ensure_all_started(:hackney)
    Application.ensure_all_started(:auth0_ex)
    [client_id | _] = argv
    Auth0Ex.Management.Client.get(client_id)
    |> case do
         {:error, error_string, _} ->
           %{"statusCode" => code, "error" => error, "message" => message} = Poison.decode!(error_string)
           IO.puts("#{code}:#{error} - #{message}")
         {:ok, result_map} -> IO.inspect result_map
       end
  end
end
