defmodule Mix.Tasks.Auth0.Client.Delete do
  use Mix.Task

  @shortdoc "Delete Auth0 clients"
  def run(argv) do
    Application.ensure_all_started(:hackney)
    Application.ensure_all_started(:auth0_ex)
    Enum.map(argv, fn client_id ->
      case Auth0Ex.Management.Client.delete(client_id) do
        :ok -> "#{client_id} - successfully deleted"
        _ -> "#{client_id} - unknown state"
      end
    end)
    |> Enum.join("\n")
    |> IO.puts
  end
end
