defmodule Mix.Tasks.User.Permissions.Clear do
  @moduledoc """
  This task is used to remove permissions from a User
"""
  use Mix.Task
  alias Tradewinds.Accounts
  alias Tradewinds.Accounts.User
  alias Tradewinds.Repo

  @doc """
  This task is used to clear all permissions from a user.
"""
  @doc since: "0.1.0"
  @shortdoc "Remove all permissions from a User"
  def run(argv) do
    Mix.Task.run "app.start"
    [user_id | _] = argv
    Accounts.get_user!(user_id)
    |> User.changeset(%{permissions: %{}})
    |> Repo.update
  end
end
