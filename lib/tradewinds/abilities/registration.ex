defmodule Tradewinds.Accounts.Registration.Abilities do
  @moduledoc """
  This module holds the logic for user authorization when accessing registration entities.
"""

  import Tradewinds.Abilities.Common
  alias Tradewinds.Accounts.Registration
  alias Tradewinds.Accounts.User
  alias Tradewinds.Events.Event

  @cannot_change_history {:error, "Historic records are not editable"}
  @permissions [:read, :write, :list, :delete, :create]
  @access_permissions [:list, :create]
  @historically_pertinent_actions [:write, :delete]

  @doc """
  The can?/3 function defines what a User is able to do with an instance of a Registration.

  THe current authorization rules are as follows, applied in order.

  If the registration is in the past, it cannot be edited or deleted.
  If the current user is the user on the registration, full access.
  If the current user has permissions for an action, they can perform that action
  Otherwise deny the action.

  Return {:ok, true} or {:error, "some message"}
"""
  @doc since: "0.1.0"
  def can?(user, action, registration)
  def can?(%User{pk: current_user_id, permissions: perms}, action, %Registration{user: %User{pk: user_id}, event: %Event{start: start}}) when action in @historically_pertinent_actions do
    cond do
      historical?(start) -> @cannot_change_history
      current_user_id == user_id -> approved()
      perm?(perms, :registration, action) -> approved()
      true -> no_instance_permission("registration")
    end
  end

  def can?(%User{pk: current_user_id, permissions: perms}, :read, %Registration{user: %User{pk: user_id}}) do
    cond do
      current_user_id == user_id -> approved()
      perm?(perms, :registration, :read) -> approved()
      true -> no_instance_permission("registration")
    end
  end

  @doc """
  This function determines what Registration related actions a user can perform.

  Return `{:ok, true}` or `{:error, "Current user does not have permission to access this content"}`

  ## Examples:
    iex> Tradewinds.Accounts.Registration.Abilities.can?(%User{pk: 1, permissions: %{registration: [:list]}}, :list)
    {:ok, true}
    iex> Tradewinds.Accounts.Registration.Abilities.can?(%User{pk: 1, permissions: %{registration: [:list]}}, :create)
    {:error, "Current user does not have permission to access this content"}
    iex> Tradewinds.Accounts.Registration.Abilities.can?(%User{pk: 1, permissions: %{registration: []}}, :create)
    {:error, "Current user does not have permission to access this content"}
    iex> Tradewinds.Accounts.Registration.Abilities.can?(%User{pk: 1, permissions: %{}}, :create)
    {:error, "Current user does not have permission to access this content"}
"""
  @doc since: "0.1.0"
  def can?(%User{permissions: perms}, action) when action in @access_permissions do
    if perm?(perms, :registration, action) do
      approved()
    else
      no_access_permission()
    end
  end

  @doc """
  This function returns the full permission set used in authorization

  ## Example:
    iex> Tradewinds.Accounts.Registration.Abilities.permissions()
    [:read, :write, :list, :delete, :create]
"""
  @doc since: "0.1.0"
  def permissions do
    @permissions
  end
end
