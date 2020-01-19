defmodule Tradewinds.Repo.Migrations.CreateRegistrations do
  use Ecto.Migration

  def change do
    create table(:registrations) do
      add :selection, :map
      add(:event_id, references(:events), null: false)
      add :user_id, references(:users)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:registrations, [:event_id, :user_id], name: :rego_uniqueness)
    execute("CREATE INDEX open_registrations_index ON registrations(user_id) WHERE user_id IS NULL")
    execute("CREATE INDEX no_selection_made ON registrations(selection) WHERE selection IS NULL")
  end
end
