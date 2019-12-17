defmodule Tradewinds.Accounts.User.Abilities do
  alias Tradewinds.Accounts.User

  require Logger

  defimpl Canada.Can, for: User do
    @allowed_self_actions [:show, :edit, :update]

    def can?(%User{id: current_user_id, permissions: perms}, :delete, %User{id: user_id}) do
      case current_user_id == user_id do
        true ->
          {:error, "You cannot delete yourself"}
        false ->
          case Enum.member?(perms[:user], :delete) do
            true ->
              {:ok, true}
            false ->
              {:error, "Current user does not have permission to delete users."}
          end
      end
    end

    def can?(%User{permissions: perms}, action, User) do
      Logger.debug("Perms: #{inspect perms}")
      case Map.get(perms, :user, nil) do
        nil ->
          {:error, "Current user does not have permission to access this content"}
        user_perms ->
          case Enum.member?(user_perms, action) do
            false -> {:error, "Current user does not have permission to access this content"}
            true -> {:ok, true}
          end
      end
    end

    def can?(%User{id: current_user_id, permissions: perms}, action, %User{id: user_id}) do
      case current_user_id == user_id do
        true ->
          case Enum.member?(@allowed_self_actions, action) do
            true -> {:ok, true}
            false -> {:error, "User cannot perform this action on themself"}
          end
        false ->
          case Map.get(perms, :user, nil) do
            nil -> {:error, "Current user does not have permission to perform this action on this user."}
            user_perms ->
              case Enum.member?(user_perms, action) do
                false -> {:error, "Current user does not have permission to perform this action on this user."}
                true -> {:ok, true}
              end
          end
      end
    end

    def can?(_, _, _) do
      {:error, "Hit the anything case"}
    end
  end
end
