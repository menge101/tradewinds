defmodule Tradewinds.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :permissions, {:array, :string}
      add :auth0_id, :string

      timestamps()
    end

  end
end
