defmodule Mix.Tasks.Auth0.User.Delete do
  use Mix.Task

  @shortdoc "Delete a user in Auth0"
  def run(argv) do
    Application.ensure_all_started(:hackney)
    [ id | _ ] = argv
    IO.inspect(Auth0Ex.Management.User.delete(id))
  end
end
