defmodule Tradewinds.Trails.Trail.Abilities do
  alias Tradewinds.Trails.Trail
  alias Tradewinds.Accounts.User

  @no_instance_permission {:error, "Current user does not have permission to perform this action on this trail."}
  @no_access_permission {:error, "Current user does not have permission to access this content"}
  @cannot_change_history {:error, "Historic records are not editable"}
  @approved {:ok, true}
  @permissions [:read, :write, :list, :delete, :create]

  def can?(%User{id: user_id, permissions: perms}, :delete, %Trail{owners: owners, start: start}) do
    case Enum.member?(owners, user_id) do
      true ->
        can_historical(start)
      false ->
        case Map.get(perms, :trail, nil) do
          nil -> @no_instance_permission
          trail_perms ->
            case Enum.member?(trail_perms, :delete) do
              false -> @no_instance_permission
              true -> can_historical(start)
            end
        end
    end
  end

  def can?(%User{id: user_id, permissions: perms}, :write, %Trail{start: start, owners: owners}) do
    case Enum.member?(owners, user_id) do
      true -> can_historical(start)
      false ->
        case Map.get(perms, :trail, nil) do
          nil -> @no_instance_permission
          trail_perms ->
            case Enum.member?(trail_perms, :write) do
              false -> @no_instance_permission
              true -> can_historical(start)
            end
        end
    end
  end

  def can?(%User{permissions: perms}, :create, _) do
    case Map.get(perms, :trail, nil) do
      nil -> @no_access_permission
      trail_perms ->
        case Enum.member?(trail_perms, :create) do
          false -> @no_access_permission
          true -> @approved
        end
    end
  end

  def can?(%User{}, action, _) do
    case Enum.member?(@permissions, action) do
      true -> @approved
      false -> @no_access_permission
    end
  end

  def permissions do
    @permissions
  end

  defp can_historical(start) do
    case DateTime.now("Etc/UTC") do
      {:ok, current} ->
        case DateTime.compare(start, current) do
          :gt -> @approved
          :eq -> @cannot_change_history
          :lt -> @cannot_change_history
        end
      any -> any
    end
  end
end
