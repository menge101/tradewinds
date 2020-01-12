defmodule Mix.Tasks.Auth0.User.Create do
  @moduledoc """
  This task is used to create a user in Auth0.
"""
  use Mix.Task
  alias Auth0Ex.Management.User

  @doc """
  Creates a new use in Auth0
"""
  @doc since: "0.1.0"
  @shortdoc "Create a new user in Auth0"
  def run(argv) do
    Application.ensure_all_started(:hackney)
    Application.ensure_all_started(:auth0_ex)
    connection = Application.fetch_env!(:auth0_ex, :connection)
    [email | [password | _remaining]] = argv
    # credo:disable-for-next-line Credo.Check.Warning.IoInspect
    IO.inspect(User.create(connection, %{email: email, password: password}))
  end
end
