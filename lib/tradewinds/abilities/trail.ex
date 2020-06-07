defmodule Tradewinds.Trails.Trail.Abilities do
  @moduledoc """
  This module holds the logic for user authorization when accessing trail entities.
"""

  import Tradewinds.Abilities.Common
  alias Tradewinds.Accounts.User
  alias Tradewinds.Trails.Trail

  @cannot_change_history {:error, "Historic records are not editable"}
  @permissions [:read, :write, :list, :delete, :create]
  @historically_pertinent_actions [:write, :delete]

  @doc """
  The can?/3 function defines what a User is able to do with an instance of a Trail based on characteristics of the Trail instance itself.
  This is used within the controllers for authorization.

  The current authorization rules are as follows, and are applicable in this order.

  If it is historical, it cannot be altered.
  If the User is an owner, allow the request.
  If the user has permission for the action, allow the request.
  If the request is a `:read`, allow it.
  Otherwise, user's request is denied.

  Return `{:ok, true}` or `{:error, "some message"}`

  ## Examples:
    iex> Tradewinds.Trails.Trail.Abilities.can?(%User{pk: 1, permissions: %{trail: [:write]}}, :write, %Trail{start: ~U[2000-04-17 14:00:00Z], owners: [1]})
    {:error, "Historic records are not editable"}
    iex> Tradewinds.Trails.Trail.Abilities.can?(%User{pk: 1, permissions: %{trail: [:delete]}}, :write, %Trail{start: ~U[2100-04-17 14:00:00Z], owners: [1]})
    {:ok, true}
    iex> Tradewinds.Trails.Trail.Abilities.can?(%User{pk: 1, permissions: %{trail: [:write]}}, :write, %Trail{start: ~U[2100-04-17 14:00:00Z], owners: [2]})
    {:ok, true}
    iex> Tradewinds.Trails.Trail.Abilities.can?(%User{pk: 1, permissions: %{trail: [:delete]}}, :write, %Trail{start: ~U[2100-04-17 14:00:00Z], owners: [2]})
    {:error, "Current user does not have permission to perform this action on this trail."}
    iex> Tradewinds.Trails.Trail.Abilities.can?(%User{}, :read, %Trail{})
    {:ok, true}
"""
  @doc since: "0.1.0"
  def can?(user, action, trail)
  def can?(%User{pk: user_id, permissions: perms}, action, %Trail{owners: owners, start: start}) when action in @historically_pertinent_actions do
    cond do
      historical?(start) -> @cannot_change_history
      Enum.member?(owners, user_id) -> approved()
      perm?(perms, :trail, action) -> approved()
      true -> no_instance_permission()
    end
  end

  def can?(%User{}, :read, %Trail{}), do: approved()

  @doc """
  The can?/2 function defines what Trail related actions a User is able to perform.

  In the case of the `:create` action, it is allowed if the user has permission.
  The `:list` action is always allowed.

  Return `{:ok, true}` or `{:error, "some message"}`

  ## Examples:
    iex> Tradewinds.Trails.Trail.Abilities.can?(%User{pk: 1, permissions: %{trail: [:create]}}, :create)
    {:ok, true}
    iex> Tradewinds.Trails.Trail.Abilities.can?(%User{pk: 1, permissions: %{trail: [:list]}}, :create)
    {:error, "Current user does not have permission to access this content"}
    iex> Tradewinds.Trails.Trail.Abilities.can?(%User{pk: 1, permissions: %{trail: [:list]}}, :list)
    {:ok, true}
    iex> Tradewinds.Trails.Trail.Abilities.can?(%User{pk: 1, permissions: %{trail: [:create]}}, :list)
    {:ok, true}
"""
  @doc since: "0.1.0"
  def can?(user, action)
  def can?(%User{permissions: perms}, :create) do
    case perm?(perms, :trail, :create) do
      true -> approved()
      false -> no_access_permission()
    end
  end

  def can?(%User{}, :list), do: approved()

  @doc """
  This function defines the no_instance_permission response for Tradewinds.Trails.Trail.Abilities.

  Return {:error, "Current user does not have permission to perform this action on this trail."}

  ## Examples:
    iex> Tradewinds.Trails.Trail.Abilities.no_instance_permission()
    {:error, "Current user does not have permission to perform this action on this trail."}
"""
  @doc since: "0.1.0"
  def no_instance_permission do
    {:error, "Current user does not have permission to perform this action on this trail."}
  end

  @doc """
  This function returns the available permissions for a Tradewinds.Trails.Trail entity.

  Return [:read, :write, :list, :delete, :create]

  ## Examples:
    iex> Tradewinds.Trails.Trail.Abilities.permissions
    [:read, :write, :list, :delete, :create]
"""
  @doc since: "0.1.0"
  def permissions do
    @permissions
  end
end
