defmodule Tradewinds.Repo.Migrations.CreateTrails do
  use Ecto.Migration

  def change do
    create table(:trails) do
      add :name, :string
      add :description, :string
      add :start, :utc_datetime
      add :hares, {:array, :id}
      add :owners, {:array, :id}
      add :creator, :id

      timestamps(type: :utc_datetime)
    end

  end
end
