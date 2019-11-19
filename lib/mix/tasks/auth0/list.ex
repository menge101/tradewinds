defmodule Mix.Tasks.Auth0.List do
  use Mix.Task

  @shortdoc "List all users in Auth0"
  def run(argv) do
    Application.ensure_all_started(:hackney)
    case argv do
      [] -> IO.inspect(Auth0Ex.Management.User.all())
      [_ | _] ->
        fields = argv |> Enum.join(",")
        IO.inspect(Auth0Ex.Management.User.all(fields: fields))
    end

  end
end
