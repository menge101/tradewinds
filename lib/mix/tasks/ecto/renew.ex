defmodule Mix.Tasks.Ecto.Renew do
  use Mix.Task

  @shortdoc "Renews the DB, by dropping, creating, and migrating it"
  def run(argv) do
    Mix.Tasks.Ecto.Drop.run(argv)
    Mix.Tasks.Ecto.Create.run(argv)
    Mix.Tasks.Ecto.Migrate.run(argv)
  end
end
