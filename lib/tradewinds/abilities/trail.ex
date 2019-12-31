defmodule Tradewinds.Trails.Trail.Abilities do
  @moduledoc """
  This module holds the logic for user authorization when accessing trail entities.
"""

  import Tradewinds.Abilities.Common
  alias Tradewinds.Accounts.User
  alias Tradewinds.Exceptions.GetTimeError
  alias Tradewinds.Trails.Trail

  @cannot_change_history {:error, "Historic records are not editable"}
  @permissions [:read, :write, :list, :delete, :create]

  def can?(%User{id: user_id, permissions: perms}, :delete, %Trail{owners: owners, start: start})  do
    cond do
      historical?(start) -> @cannot_change_history
      Enum.member?(owners, user_id) -> approved()
      perm?(perms, :trail, :delete) -> approved()
      true -> no_instance_permission()
    end
  end

  def can?(%User{id: user_id, permissions: perms}, :write, %Trail{start: start, owners: owners}) do
    cond do
      historical?(start) -> @cannot_change_history
      Enum.member?(owners, user_id) -> approved()
      perm?(perms, :trail, :write) -> approved()
      true -> no_instance_permission()
    end
  end

  def can?(%User{permissions: perms}, :create, _) do
    case perm?(perms, :trail, :create) do
      true -> approved()
      false -> no_access_permission()
    end
  end

  def can?(%User{}, action, _) do
    case Enum.member?(@permissions, action) do
      true -> approved()
      false -> no_access_permission()
    end
  end

  def permissions do
    @permissions
  end

  def historical?(start) do
    case DateTime.now("Etc/UTC") do
      {:ok, current} ->
        case DateTime.compare(start, current) do
          :gt -> false
          :eq -> false
          :lt -> true
        end
      _ -> raise GetTimeError
    end
  end

  def no_instance_permission do
    {:error, "Current user does not have permission to perform this action on this trail."}
  end
end
