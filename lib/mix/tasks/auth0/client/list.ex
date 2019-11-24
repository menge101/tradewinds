defmodule Mix.Tasks.Auth0.Client.List do
  use Mix.Task

  @shortdoc "List all clients in Auth0"
  def run(argv) do
    Application.ensure_all_started(:hackney)
    Application.ensure_all_started(:auth0_ex)
    case argv do
      [] -> Auth0Ex.Management.Client.all()
      non_empty ->
        Auth0Ex.Management.Client.all(%{fields: Enum.join(non_empty, ",")})
    end
    |> case do
         {:ok, results} -> IO.inspect results
         anything_else -> IO.inspect anything_else
       end
  end
end
