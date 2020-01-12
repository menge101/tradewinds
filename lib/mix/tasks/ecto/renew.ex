defmodule Mix.Tasks.Ecto.Renew do
  @moduledoc """
  This task renews the DB,
  and may actually be a re-implementation of something that was already on offer in the ecto suite of tasks.
"""
  use Mix.Task
  alias Mix.Tasks.Ecto

  @doc """
  This task is used to drop, create, and migrate the DB in one shot.
"""
  @doc since: "0.1.0"
  @shortdoc "Renews the DB, by dropping, creating, and migrating it"
  def run(argv) do
    Ecto.Drop.run(argv)
    Ecto.Create.run(argv)
    Ecto.Migrate.run(argv)
  end
end
