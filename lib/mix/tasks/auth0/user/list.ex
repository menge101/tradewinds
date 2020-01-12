defmodule Mix.Tasks.Auth0.User.List do
  @moduledoc """
  This task is used to list all users in Auth0
"""
  use Mix.Task
  alias Auth0Ex.Management.User

  @doc """
  Lists all Auth0 users.
"""
  @doc since: "0.1.0"
  @shortdoc "List all users in Auth0"
  def run(argv) do
    Application.ensure_all_started(:hackney)
    Application.ensure_all_started(:auth0_ex)
    case argv do
      # credo:disable-for-next-line Credo.Check.Warning.IoInspect
      [] -> IO.inspect(User.all())
      [_ | _] ->
        fields = argv |> Enum.join(",")
        # credo:disable-for-next-line Credo.Check.Warning.IoInspect
        IO.inspect(User.all(fields: fields))
    end
  end
end
