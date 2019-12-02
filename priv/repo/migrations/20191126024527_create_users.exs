defmodule Tradewinds.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :permissions, {:map, {:array, :string}}
      add :auth0_id, :string
      add :avatar_link, :string
      add :email, :string

      timestamps()
    end

    create unique_index(:users, [:auth0_id])
  end
end
