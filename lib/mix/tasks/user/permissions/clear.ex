defmodule Mix.Tasks.User.Permissions.Clear do
  use Mix.Task
  alias Tradewinds.Accounts
  alias Tradewinds.Accounts.User
  alias Tradewinds.Repo

  @shortdoc "Adds a set of permissions to a User"
  def run(argv) do
    Mix.Task.run "app.start"
    [ user_id | _ ] = argv
    Accounts.get_user!(user_id)
    |> User.changeset(%{permissions: %{}})
    |> Repo.update
  end
end