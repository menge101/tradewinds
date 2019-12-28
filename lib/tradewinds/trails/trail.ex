defmodule Tradewinds.Trails.Trail do
  @moduledoc """
  Trails - Trail model
"""
  use Ecto.Schema
  import Ecto.Changeset

  schema "trails" do
    field :description, :string
    field :name, :string
    field :start, :utc_datetime
    field :hares, {:array, :id}
    field :owners, {:array, :id}
    field :creator, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(trail, attrs) do
    trail
    |> cast(attrs, [:name, :description, :start, :creator])
    |> set_blank_owners
    |> validate_required([:name, :description, :start, :creator, :owners])
  end

  defp set_blank_owners(changeset) do
    case get_field(changeset, :owners) do
      nil -> put_change(changeset, :owners, [get_field(changeset, :creator)])
      [] -> put_change(changeset, :owners, [get_field(changeset, :creator)])
      _ -> changeset
    end
  end
end
