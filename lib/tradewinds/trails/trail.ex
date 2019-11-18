defmodule Tradewinds.Trails.Trail do
  use Ecto.Schema
  import Ecto.Changeset

  schema "trails" do
    field :desription, :string
    field :name, :string
    field :start, :naive_datetime

    timestamps()
  end

  @doc false
  def changeset(trail, attrs) do
    trail
    |> cast(attrs, [:name, :desription, :start])
    |> validate_required([:name, :desription, :start])
  end
end
