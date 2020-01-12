defmodule Mix.Tasks.User.Permissions.Add do
  @moduledoc """
  This task is used to add a set of permissions to a User
"""
  use Mix.Task
  alias Tradewinds.Accounts
  alias Tradewinds.Accounts.User
  alias Tradewinds.Repo

  @doc """
  This task is used to add a set of permissions to a user.
"""
  @doc since: "0.1.0"
  @shortdoc "Adds a set of permissions to a User"
  def run(argv) do
    Mix.Task.run "app.start"
    [user_id | [module | perm_list]] = argv
    user = Accounts.get_user!(user_id)
    Map.get(user.permissions, module, [])
    |> Enum.concat(perm_list)
    |> Enum.dedup
    |> fn new_perms ->
         User.changeset(user, %{permissions: Map.put(user.permissions, String.to_atom(module), new_perms)})
       end.()
    |> Repo.update
  end
end
