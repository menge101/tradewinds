defmodule Tradewinds.Accounts.Registration do
  @moduledoc """
    This module is home to the schema for Registration table
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Tradewinds.Accounts.Registration
  alias Tradewinds.Accounts.User
  alias Tradewinds.Events
  alias Tradewinds.Events.Event
  alias Tradewinds.Fixtures.Common
  alias Tradewinds.Repo

  @castable [:selection]

  schema "registrations" do
    field :selection, :map
    belongs_to :event, Event
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc """
  The changeset/2 function is intended to handle the data within a create or update operation.

  There are a lot of clauses to this function due to its need to handle all sorts of permutations between the
  Registration and Event existing, not existing, or being nil.

  An Event is required for a registration, but a User is not.  This should facilitate ticket style creation of registrations.
"""
  @doc since: "0.1.0"
  def changeset(registration, attrs)
  def changeset(registration, attrs) when attrs == %{} do
    registration
    |> cast(attrs, @castable)
    |> add_error(:event, "Event is required")
  end

  def changeset(registration, %{event: nil} = attrs) do
    registration
    |> cast(attrs, @castable)
    |> add_error(:event, "Event is required")
  end

  def changeset(%Registration{} = registration, %{event: %{}} = attrs) do
    registration
    |> cast(attrs, @castable)
    |> event_assoc(attrs)
    |> user_assoc(attrs)
    |> assoc_constraint(:event)
    |> unique_constraint(:rego_uniqueness, name: :rego_uniqueness)
  end

  def changeset(%Registration{} = registration, %{"event" => %{}} = attrs) do
    registration
    |> cast(attrs, @castable)
    |> event_assoc(attrs)
    |> user_assoc(attrs)
    |> assoc_constraint(:event)
    |> unique_constraint(:rego_uniqueness, name: :rego_uniqueness)
  end

  def changeset(%Registration{id: id} = registration, %{event: %{} = event} = attrs) do
    registration
    |> cast(Map.put(attrs, :id, id), @castable ++ [:id])
    |> event_assoc(attrs)
    |> user_assoc(attrs)
    |> assoc_constraint(:event)
    |> unique_constraint(:rego_uniqueness, name: :rego_uniqueness)
  end

  def changeset(%Registration{event_id: event_id, id: id} = registration, %{} = attrs) do
    registration
    |> load_unless_loaded(:event)
    |> load_unless_loaded(:user)
    |> cast(Map.put(attrs, "id", id), @castable ++ [:id])
    |> event_assoc(attrs)
    |> user_assoc(attrs)
    |> assoc_constraint(:event)
    |> unique_constraint(:rego_uniqueness, name: :rego_uniqueness)
  end

  def changeset(%Registration{event_id: event_id} = registration, %{} = attrs) do
    registration
    |> cast(attrs, @castable)
    |> add_error(:event, "Event is required")
  end

  def event_assoc(changeset, attrs)
  def event_assoc(changeset, %{event: %{__meta__: _} = event}) do
    put_assoc(changeset, :event, event)
  end

  def event_assoc(changeset, %{event: %{}}) do
    cast_assoc(changeset, :event, with: &Event.changeset/2)
  end

  def event_assoc(changeset, %{"event" => %{}}) do
    cast_assoc(changeset, :event, with: &Event.changeset/2)
  end

  def event_assoc(changeset, %{}), do: changeset

  def user_assoc(changeset, attrs)
  def user_assoc(changeset, %{user: %{__meta__: _} = user}) do
    put_assoc(changeset, :user, user)
  end

  def user_assoc(changeset, %{user: %{}}) do
    cast_assoc(changeset, :user, with: &User.changeset/2)
  end

  def user_assoc(changeset, %{"user" => %{}}) do
    cast_assoc(changeset, :user, with: &User.changeset/2)
  end
  def user_assoc(changeset, %{}), do: changeset

  defp load_unless_loaded(registration, association) do
    if Ecto.assoc_loaded?(Map.get(registration, association)) do
      registration
    else
      Repo.preload(registration, [association])
    end
  end
end
