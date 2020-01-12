defmodule Tradewinds.Events.Event.Abilities do
  @moduledoc """
  This module holds the logic for event authorization.
"""

  import Tradewinds.Abilities.Common

  alias Tradewinds.Accounts.User
  alias Tradewinds.Events.Event

  @access_permissions [:create, :list]
  @instance_permissions [:read, :write, :delete]

  @doc """
  The can?/3 function defines what a User is able to do with an instance of an Event based on various criteria.
  This is used within the controllers for authorization.

  The current authorization rules are as follows, and are applicable in this order.

  If the User has a permission for :event, matching the requested action, allow it.
  If there are no admins on the event, return no instance permission.
  If the user is an admin for the :event, allow the action.
  For anything else, no instance permission.

  Return `{:ok, true}` or `{:error, "some message"}`

  ## Examples:
    iex> Tradewinds.Events.Event.Abilities.can?(%User{id: 1, permissions: %{event: [:read]}}, :read, %Event{admins: []})
    {:ok, true}
    iex> Tradewinds.Events.Event.Abilities.can?(%User{id: 1, permissions: %{event: [:read]}}, :write, %Event{admins: []})
    {:error, "Current user does not have permission to perform this action on this event."}
    iex> Tradewinds.Events.Event.Abilities.can?(%User{id: 1, permissions: %{event: [:read]}}, :write, %Event{admins: nil})
    {:error, "Current user does not have permission to perform this action on this event."}
    iex> Tradewinds.Events.Event.Abilities.can?(%User{id: 1, permissions: %{event: [:read]}}, :write, %Event{})
    {:error, "Current user does not have permission to perform this action on this event."}
    iex> Tradewinds.Events.Event.Abilities.can?(%User{id: 1, permissions: %{}}, :read, %Event{admins: [1]})
    {:ok, true}
    iex> Tradewinds.Events.Event.Abilities.can?(%User{id: 1, permissions: %{}}, :read, %Event{admins: [3]})
    {:error, "Current user does not have permission to perform this action on this event."}

"""
  @doc since: "0.1.0"
  def can?(%User{id: user_id,  permissions: perms}, action, %Event{admins: admins}) when action in @instance_permissions do
    cond do
      perm?(perms, :event, action) -> approved()
      admins == nil -> no_instance_permission()
      Enum.member?(admins, user_id) -> approved()
      true -> no_instance_permission()
    end
  end

  @doc """
    The can?/2 function defines what Event related actions a User is able to perform.
    This is used within the controllers for authorization.

    The current authorization rules are as follows, and are applicable in this order.


    If the User has a permission for :event, matching the requested action, allow it.
    For anything else, no access permission.

    Return `{:ok, true}` or `{:error, "some message"}`

    It should be noted that a guard statement is used to only allow action types that are in the
    list `@access_permissions [:create, :list]`

    ## Examples:
      iex> Tradewinds.Events.Event.Abilities.can?(%User{id: 1, permissions: %{event: [:list]}}, :list)
      {:ok, true}
      iex> Tradewinds.Events.Event.Abilities.can?(%User{id: 1, permissions: %{event: [:read]}}, :read)
      ** (FunctionClauseError) no function clause matching in Tradewinds.Events.Event.Abilities.can?/2
      iex> Tradewinds.Events.Event.Abilities.can?(%User{id: 1, permissions: %{event: [:list]}}, :create)
      {:error, "Current user does not have permission to access this content"}
  """
  @doc since: "0.1.0"
  def can?(%User{permissions: perms}, action) when action in @access_permissions do
    if perm?(perms, :event, action) do
      approved()
    else
      no_access_permission()
    end
  end

  @doc """
  This functions defines the no_instance_permission response for the Tradewinds.Events.Event module
"""
  @doc since: "0.1.0"
  def no_instance_permission do
    {:error, "Current user does not have permission to perform this action on this event."}
  end
end
