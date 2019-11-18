defmodule Tradewinds.Repo.Migrations.CreateTrails do
  use Ecto.Migration

  def change do
    create table(:trails) do
      add :name, :string
      add :desription, :string
      add :start, :naive_datetime

      timestamps()
    end

  end
end
