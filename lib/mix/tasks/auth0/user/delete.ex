defmodule Mix.Tasks.Auth0.User.Delete do
  @moduledoc """
  This task is used to remove a User from Auth0
"""
  use Mix.Task
  alias Auth0Ex.Management.User

  @doc """
  Deletes a specific Auth0 user.
"""
  @doc since: "0.1.0"
  @shortdoc "Delete a user in Auth0"
  def run(argv) do
    Application.ensure_all_started(:hackney)
    Application.ensure_all_started(:auth0_ex)
    [id | _] = argv
    # credo:disable-for-next-line Credo.Check.Warning.IoInspect
    IO.inspect(User.delete(id))
  end
end
