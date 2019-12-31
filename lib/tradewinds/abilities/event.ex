defmodule Tradewinds.Events.Event.Abilities do
  @moduledoc """
  This module holds the logic for event authorization.
"""

  import Tradewinds.Abilities.Common

  alias Tradewinds.Accounts.User
  alias Tradewinds.Events.Event

  @access_permissions [:create, :list]
  @instance_permissions [:read, :write, :delete]

  def can?(%User{id: user_id,  permissions: perms}, action, %Event{admins: admins}) do
    cond do
      perm?(perms, :event, action) -> approved()
      admins == nil -> no_access_permission()
      Enum.member?(admins, user_id) ->
        if Enum.member?(@instance_permissions, action) do
          approved()
        else
          invalid_request("Event", action)
        end
      Enum.member?(@access_permissions, action) -> no_access_permission()
      Enum.member?(@instance_permissions, action) -> no_instance_permission()
    end
  end

  def can?(%User{permissions: perms}, action, Event) do
    if perm?(perms, :event, action) do
      approved()
    else
      no_access_permission()
    end
  end

  def no_instance_permission do
    {:error, "Current user does not have permission to perform this action on this event."}
  end
end
