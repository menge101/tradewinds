defmodule Tradewinds.Accounts.User.Abilities do
  @moduledoc """
    This module holds the logic for User authorization based on the current logged in user, the target user,
  and the desired action.
  """
  import Tradewinds.Abilities.Common
  alias Tradewinds.Accounts.User

  require Logger

  @no_instance_permission {:error, "Current user does not have permission to perform this action on this user."}
  @cannot_delete_self {:error, "You cannot delete yourself"}
  @permissions [:list, :read, :write, :create, :delete]
  @access_perms [:list, :create]
  @instance_perms [:read, :write, :delete]

  @doc """
  The can?/3 function defines what a User is able to do with an instance of a User.
  This is used within the controllers for authorization.

  The authorization rules are as follows, and are applied in this order:

  If current user is the user, and the action is not delete, approve it.
  If current user is the user, and the action is delete, deny the request.
  If the user has the permission for the action, approve it.
  Otherwise, deny the request.

  Return `{:ok, true}` or `{:error, "some message"}`

  ## Examples:
    iex> Tradewinds.Accounts.User.Abilities.can?(%User{pk: 1, permissions: %{}}, :read, %User{pk: 1})
    {:ok, true}
    iex> Tradewinds.Accounts.User.Abilities.can?(%User{pk: 1, permissions: %{}}, :delete, %User{pk: 1})
    {:error, "You cannot delete yourself"}
    iex> Tradewinds.Accounts.User.Abilities.can?(%User{pk: 1, permissions: %{user: [:read]}}, :read, %User{pk: 2})
    {:ok, true}
    iex> Tradewinds.Accounts.User.Abilities.can?(%User{pk: 1, permissions: %{user: [:delete]}}, :delete, %User{pk: 2})
    {:ok, true}
    iex> Tradewinds.Accounts.User.Abilities.can?(%User{pk: 1, permissions: %{user: [:delete]}}, :read, %User{pk: 2})
    {:error, "Current user does not have permission to perform this action on this user."}
"""
  @doc since: "0.1.0"
  def can?(current_user, action, user)
  def can?(%User{pk: current_user_id, permissions: perms}, :delete, %User{pk: user_id}) do
    cond do
      current_user_id == user_id -> @cannot_delete_self
      perm?(perms, :user, :delete) -> approved()
      true -> @no_instance_permission
    end
  end

  def can?(%User{pk: current_user_id, permissions: perms}, action, %User{pk: user_id}) when action in @instance_perms do
    cond do
      current_user_id == user_id -> approved()
      perm?(perms, :user, action) -> approved()
      true -> @no_instance_permission
    end
  end

  @doc """
  The can?/2 function defines what User related actions the current user is able to perform.

  An action is permitted, if the user has the proper permission.  Nice and simple.

  Return `{:ok, true}` or `{:error, "some message"}`

  ## Examples:
    iex> Tradewinds.Accounts.User.Abilities.can?(%User{permissions: %{user: [:list]}}, :list)
    {:ok, true}
    iex> Tradewinds.Accounts.User.Abilities.can?(%User{permissions: %{user: [:list]}}, :create)
    {:error, "Current user does not have permission to access this content"}
"""
  @doc since: "0.1.0"
  def can?(%User{permissions: perms}, action) when action in @access_perms do
    case perm?(perms, :user, action) do
      true -> approved()
      false -> no_access_permission()
    end
  end

  @doc """
  This function returns the available permissions for a Tradewinds.Accounts.User entity.

    Return [:read, :write, :list, :delete, :create]

    ## Examples:
      iex> Enum.sort(Tradewinds.Accounts.User.Abilities.permissions)
      Enum.sort([:read, :write, :list, :delete, :create])
  """
  @doc since: "0.1.0"
  def permissions do
    @permissions
  end
end
