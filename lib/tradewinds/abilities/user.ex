defmodule Tradewinds.Accounts.User.Abilities do
  @moduledoc """
    This module holds the logic for User authorization based on the current logged in user, the target user,
  and the desired action.
  """
  import Tradewinds.Abilities.Common
  alias Tradewinds.Accounts.User

  require Logger

  @allowed_self_actions [:read, :write]
  @no_instance_permission {:error, "Current user does not have permission to perform this action on this user."}
  @no_access_permission {:error, "Current user does not have permission to access this content"}
  @cannot_delete_self {:error, "You cannot delete yourself"}
  @approved {:ok, true}
  @no_self_permission {:error, "User cannot perform this action on themselves"}
  @permissions [:list, :read, :write, :create, :delete]
  @access_perms [:list, :create]
  @instance_perms [:read, :write, :delete]

  def can?(%User{id: current_user_id, permissions: perms}, :delete, %User{id: user_id}) do
    cond do
      current_user_id == user_id -> @cannot_delete_self
      perm?(perms, :user, :delete) -> @approved
      true -> @no_instance_permission
    end
  end

  def can?(%User{permissions: perms}, action, User) when action in @access_perms do
    case perm?(perms, :user, action) do
      true -> @approved
      false -> @no_access_permission
    end
  end

  def can?(%User{id: current_user_id, permissions: perms}, action, %User{id: user_id}) when action in @instance_perms do
    cond do
      current_user_id == user_id ->
        case Enum.member?(@allowed_self_actions, action) do
          true -> @approved
          false -> @no_self_permission
        end
      perm?(perms, :user, action) -> @approved
      true -> @no_instance_permission
    end
  end

  def permissions do
    @permissions
  end
end
