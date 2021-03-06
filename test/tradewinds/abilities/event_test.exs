defmodule Tradewinds.Abilities.EventsTest do
  use Tradewinds.DataCase
  import Tradewinds.Fixtures.Event
  alias Tradewinds.Abilities.Common
  alias Tradewinds.Events.Event.Abilities

  describe "a user with only read permission" do
    setup [:create_event, :user_with_read_permission]

    test "can read a event", %{user: user, event: event} do
      assert Common.approved() == Abilities.can?(user, :read, event)
    end

    test "cannot write an event", %{user: user, event: event} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :write, event)
    end

    test "cannot delete an event", %{user: user, event: event} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :delete, event)
    end

    test "cannot list events", %{user: user} do
      assert Common.no_access_permission() == Abilities.can?(user, :list)
    end

    test "cannot create events", %{user: user} do
      assert Common.no_access_permission() == Abilities.can?(user, :create)
    end
  end

  describe "a user with only write permission" do
    setup [:create_event, :user_with_write_permission]

    test "cannot read a event", %{user: user, event: event} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :read, event)
    end

    test "can write an event", %{user: user, event: event} do
      assert Common.approved() == Abilities.can?(user, :write, event)
    end

    test "cannot delete an event", %{user: user, event: event} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :delete, event)
    end

    test "cannot list events", %{user: user} do
      assert Common.no_access_permission() == Abilities.can?(user, :list)
    end

    test "cannot create events", %{user: user} do
      assert Common.no_access_permission() == Abilities.can?(user, :create)
    end
  end

  describe "a user with only delete permission" do
    setup [:create_event, :user_with_delete_permission]

    test "cannot read a event", %{user: user, event: event} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :read, event)
    end

    test "cannot write an event", %{user: user, event: event} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :write, event)
    end

    test "can delete an event", %{user: user, event: event} do
      assert Common.approved() == Abilities.can?(user, :delete, event)
    end

    test "cannot list events", %{user: user} do
      assert Common.no_access_permission() == Abilities.can?(user, :list)
    end

    test "cannot create events", %{user: user} do
      assert Common.no_access_permission() == Abilities.can?(user, :create)
    end
  end

  describe "a user with only list permission" do
    setup [:create_event, :user_with_list_permission]

    test "cannot read a event", %{user: user, event: event} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :read, event)
    end

    test "cannot write an event", %{user: user, event: event} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :write, event)
    end

    test "cannot delete an event", %{user: user, event: event} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :delete, event)
    end

    test "can list events", %{user: user} do
      assert Common.approved() == Abilities.can?(user, :list)
    end

    test "cannot create events", %{user: user} do
      assert Common.no_access_permission() == Abilities.can?(user, :create)
    end
  end

  describe "a user with only create permission" do
    setup [:create_event, :user_with_create_permission]

    test "cannot read a event", %{user: user, event: event} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :read, event)
    end

    test "cannot write an event", %{user: user, event: event} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :write, event)
    end

    test "cannot delete an event", %{user: user, event: event} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :delete, event)
    end

    test "cannot list events", %{user: user} do
      assert Common.no_access_permission() == Abilities.can?(user, :list)
    end

    test "can create events", %{user: user} do
      assert Common.approved() == Abilities.can?(user, :create)
    end
  end

  describe "a user with no permission" do
    setup [:create_event, :user_with_no_permission]

    test "cannot read a event", %{user: user, event: event} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :read, event)
    end

    test "cannot write an event", %{user: user, event: event} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :write, event)
    end

    test "cannot delete an event", %{user: user, event: event} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :delete, event)
    end

    test "cannot list events", %{user: user} do
      assert Common.no_access_permission() == Abilities.can?(user, :list)
    end

    test "cannot create events", %{user: user} do
      assert Common.no_access_permission() == Abilities.can?(user, :create)
    end
  end

  describe "a user with invalid permission" do
    setup [:create_event, :user_with_invalid_permission]

    test "cannot read a event", %{user: user, event: event} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :read, event)
    end

    test "cannot write an event", %{user: user, event: event} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :write, event)
    end

    test "cannot delete an event", %{user: user, event: event} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :delete, event)
    end

    test "cannot list events", %{user: user} do
      assert Common.no_access_permission() == Abilities.can?(user, :list)
    end

    test "cannot create events", %{user: user} do
      assert Common.no_access_permission() == Abilities.can?(user, :create)
    end
  end

  describe "a user that is an admin" do
    setup [:create_event, :admin_with_invalid_permission]

    test "can read an event", %{user: user, event: event} do
      assert Common.approved() == Abilities.can?(user, :read, event)
    end

    test "can write an event", %{user: user, event: event} do
      assert Common.approved() == Abilities.can?(user, :write, event)
    end

    test "can delete an event", %{user: user, event: event} do
      assert Common.approved() == Abilities.can?(user, :delete, event)
    end

    test "cannot list events", %{user: user} do
      assert Common.no_access_permission == Abilities.can?(user, :list)
    end

    test "cannot create events", %{user: user} do
      assert Common.no_access_permission == Abilities.can?(user, :create)
    end
  end

  describe "a user with only read privilege, and an event with no admins" do
    setup [:create_event_wo_admins, :user_with_read_permission]

    test "user can read the event", %{user: user, event: event} do
      assert Common.approved() == Abilities.can?(user, :read, event)
    end

    test "user cannot write the event", %{user: user, event: event} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :write, event)
    end
  end

  describe "a user with only read privilege, and an event with nil admins" do
    setup [:create_event_w_nil_admins, :user_with_read_permission]

    test "user can read the event", %{user: user, event: event} do
      assert Common.approved() == Abilities.can?(user, :read, event)
    end

    test "user cannot write the event", %{user: user, event: event} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :write, event)
    end
  end

  defp create_event(_), do: fixture(:event, %{}, false)
  defp create_event_wo_admins(_), do: fixture(:event, %{admins: []}, false)
  defp create_event_w_nil_admins(_), do: fixture(:event, %{admins: nil}, false)
end
