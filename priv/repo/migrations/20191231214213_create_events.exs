defmodule Tradewinds.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :name, :string
      add :hosting_kennel, :string
      add :start, :utc_datetime
      add :end, :utc_datetime
      add :description, :string
      add :location, :string
      add :latitude, :float
      add :longitude, :float
      add :creator, :id
      add :admins, {:array, :id}

      timestamps(type: :utc_datetime)
    end

  end
end
