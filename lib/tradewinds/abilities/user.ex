defmodule Tradewinds.Accounts.User.Abilities do
  alias Tradewinds.Accounts.User

  require Logger

  @allowed_self_actions [:read, :write]
  @no_instance_permission {:error, "Current user does not have permission to perform this action on this user."}
  @no_access_permission {:error, "Current user does not have permission to access this content"}
  @cannot_delete_self {:error, "You cannot delete yourself"}
  @approved {:ok, true}
  @no_self_permission {:error, "User cannot perform this action on themselves"}
  @permissions [:list, :read, :write, :create, :delete]

  def can?(%User{id: current_user_id, permissions: perms}, :delete, %User{id: user_id}) do
    case current_user_id == user_id do
      true -> @cannot_delete_self
      false ->
        case Map.get(perms, :user, nil) do
          nil -> @no_instance_permission
          user_perms ->
            case Enum.member?(user_perms, :delete) do
              true -> @approved
              false -> @no_instance_permission
            end
        end
    end
  end

  def can?(%User{permissions: perms}, action, User) do
    case Map.get(perms, :user, nil) do
      nil -> @no_access_permission
      user_perms ->
        case Enum.member?(user_perms, action) do
          true -> @approved
          false -> @no_access_permission
        end
    end
  end

  def can?(%User{id: current_user_id, permissions: perms}, action, %User{id: user_id}) do
    case current_user_id == user_id do
      true ->
        case Enum.member?(@allowed_self_actions, action) do
          true -> @approved
          false -> @no_self_permission
        end
      false ->
        case Map.get(perms, :user, nil) do
          nil -> @no_instance_permission
          user_perms ->
            case Enum.member?(user_perms, action) do
              true -> @approved
              false -> @no_instance_permission
            end
        end
    end
  end

  def permissions do
    @permissions
  end
end
