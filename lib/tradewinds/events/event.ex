defmodule Tradewinds.Events.Event do
  @moduledoc """
  This module holds the Event schema
"""
  use Ecto.Schema
  import Ecto.Changeset

  @cast [:name, :hosting_kennel, :start, :end, :description, :location, :latitude, :longitude, :creator, :admins]
  @required [:name, :hosting_kennel, :start, :end, :description, :location, :latitude, :longitude, :creator, :admins]

  schema "events" do
    field :description, :string
    field :end, :utc_datetime
    field :hosting_kennel, :string
    field :latitude, :float
    field :location, :string
    field :longitude, :float
    field :name, :string
    field :start, :utc_datetime
    field :creator, :id
    field :admins, {:array, :id}

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, @cast)
    |> validate_required(@required)
  end
end
