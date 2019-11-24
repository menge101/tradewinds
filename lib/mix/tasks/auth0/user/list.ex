defmodule Mix.Tasks.Auth0.User.List do
  use Mix.Task

  @shortdoc "List all users in Auth0"
  def run(argv) do
    Application.ensure_all_started(:hackney)
    Application.ensure_all_started(:auth0_ex)
    case argv do
      [] -> IO.inspect(Auth0Ex.Management.User.all())
      [_ | _] ->
        fields = argv |> Enum.join(",")
        IO.inspect(Auth0Ex.Management.User.all(fields: fields))
    end

  end
end
