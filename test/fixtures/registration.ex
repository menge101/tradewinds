defmodule Tradewinds.Fixtures.Registration do
  @moduledoc """
  This module is home to all registration related fixtures.
"""
  alias Tradewinds.Accounts
  alias Tradewinds.Fixtures.Event
  alias Tradewinds.Fixtures.User, as: UserFix

  @doc """
  This function is used to add an Event to the Registration

  ## Examples:
    iex> Tradewinds.Fixtures.Registration.add_event(%{event: nil})
    %{event: nil}
"""
  @doc since: "0.1.0"
  def add_event(%{event: nil} = attrs), do: attrs
  def add_event(%{event: _} = attrs) do
    Event.fixture(:event, attrs.event, false)
    |> elem(1)
    |> Keyword.get(:event)
    |> Map.from_struct()
    |> Map.delete(:__meta__)
    |> (fn event -> Map.put(attrs, :event, event) end).()
  end

  def add_event(%{} = attrs) do
    Event.fixture(:event, %{}, false)
    |> elem(1)
    |> Keyword.get(:event)
    |> Map.from_struct()
    |> Map.delete(:__meta__)
    |> (fn event -> Map.put(attrs, :event, event) end).()
  end

  @doc since: "0.1.0"
  def add_user(%{user: nil} = attrs), do: attrs
  def add_user(%{user: _} = attrs) do
    UserFix.fixture(:user, attrs.user)
    |> Map.from_struct()
    |> Map.delete(:__meta__)
    |> (fn user -> Map.put(attrs, :user, user) end).()
  end

  def add_user(%{} = attrs) do
    UserFix.fixture(:user, %{})
    |> Map.from_struct()
    |> Map.delete(:__meta__)
    |> (fn user -> Map.put(attrs, :user, user) end).()
  end

  @doc """
  This function is used to create the attribute set for the registration fixture

"""
  @doc since: "0.1.0"
  def create_attrs(overloads \\ %{}, _persist \\ true) do
    %{selection: nil}
    |> Map.merge(overloads)
    |> add_event
    |> add_user
  end

  @doc """
  This function defines the actual fixture.
"""
  @doc since: "0.1.0"
  def fixture(atom, attrs \\ %{}, persist \\ false)
  def fixture(:registration, attrs, true) do
    create_attrs(attrs, false)
    |> Accounts.create_registration
    |> elem(1)
    |> (fn rego -> {:ok, registration: rego} end).()
  end

  def fixture(:registration, attrs, false) do
    create_attrs(attrs, false)
    |> (fn rego -> {:ok, registration: rego} end).()
  end
end
