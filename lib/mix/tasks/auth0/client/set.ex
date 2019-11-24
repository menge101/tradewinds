defmodule Mix.Tasks.Auth0.Client.Set do
  use Mix.Task

  @doc """
    Set a Auth0 client as active.

    This essentially means setting the relevant ENV variables so that the client it used.

    This task relies on the the following environment variables being set:
    AUTH0_MGMT_TOKEN
    AUTH0_DOMAIN
    This information can be found in the Auth0 account.

    This task should be used as follows:
    `$(mix Auth0.Client.set name)`

    If the client is not uniquely named, this task will error.

    This task is meant as a configuration setup task.  This task sets ENV vars, which are read at startup by the system.
    If the primary application is already running, this will not cause any change.
  """

  @shortdoc "Set active Auth0 client"
  def run(argv) do
    Application.ensure_all_started(:hackney)
    Application.ensure_all_started(:auth0_ex)
    [name | _] = argv
    Auth0Ex.Management.Client.all(%{fields: "name,client_id"})
    |> case do
         {:ok, results} -> Enum.filter(results, fn result -> result["name"] == name end)
         |> case do
           [] ->
             IO.puts("Client with name: #{name} not found")
             exit({:error, 1})
           [client | []] ->
             Auth0Ex.Management.Client.get(client["client_id"])
           [_, _] ->
             IO.puts("Ambiguous client match")
             exit({:error, 1})
           end
           |> case do
                {:error, error_string, _} ->
                  %{"statusCode" => code, "error" => error, "message" => message} = Poison.decode!(error_string)
                  IO.puts("#{code}:#{error} - #{message}")
                {:ok, %{"client_id" => id, "client_secret" => secret}} ->
                  IO.puts("export AUTH0_CLIENT_ID=#{id}")
                  IO.puts("export AUTH0_CLIENT_SECRET=#{secret}")
              end
       end
  end
end
