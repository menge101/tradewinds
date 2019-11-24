defmodule Mix.Tasks.Auth0.User.Create do
  use Mix.Task

  @shortdoc "Create a new user in Auth0"
  def run(argv) do
    Application.ensure_all_started(:hackney)
    Application.ensure_all_started(:auth0_ex)
    connection = Application.fetch_env!(:auth0_ex, :connection)
    [ email | [password | _remaining] ] = argv
    IO.inspect(Auth0Ex.Management.User.create(connection, %{email: email, password: password}))
  end
end
