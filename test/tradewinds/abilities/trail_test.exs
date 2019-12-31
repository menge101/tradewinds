defmodule Tradewinds.Abilities.TrailsTest do
  use Tradewinds.DataCase
  import Tradewinds.Fixtures.Trail
  alias Tradewinds.Abilities.Common
  alias Tradewinds.Trails.Trail.Abilities

  describe "a trail in the past" do
    setup [:create_old_trail, :user_with_all_permission]

    test "can be read", %{user: user, trail: trail} do
      assert Common.approved() == Abilities.can?(user, :read, trail)
    end

    test "cannot be written", %{user: user, trail: trail} do
      assert cannot_change_history() == Abilities.can?(user, :write, trail)
    end

    test "cannot be deleted", %{user: user, trail: trail} do
      assert cannot_change_history() == Abilities.can?(user, :delete, trail)
    end
  end

  describe "a user with only read permission" do
    setup [:create_trail, :user_with_read_permission]

    test "can read a trail", %{user: user, trail: trail} do
      assert Common.approved() == Abilities.can?(user, :read, trail)
    end

    test "cannot write a trail", %{user: user, trail: trail} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :write, trail)
    end

    test "cannot delete a trail", %{user: user, trail: trail} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :delete, trail)
    end

    test "can list trails", %{user: user, trail: trail} do
      assert Common.approved() == Abilities.can?(user, :list, trail)
    end

    test "cannot create trails", %{user: user, trail: trail} do
      assert Common.no_access_permission() == Abilities.can?(user, :create, trail)
    end
  end

  describe "a user with only write permission" do
    setup [:create_trail, :user_with_write_permission]

    test "can read a trail", %{user: user, trail: trail} do
      assert Common.approved() == Abilities.can?(user, :read, trail)
    end

    test "can write a trail", %{user: user, trail: trail} do
      assert Common.approved() == Abilities.can?(user, :write, trail)
    end

    test "cannot delete a trail", %{user: user, trail: trail} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :delete, trail)
    end

    test "can list trails", %{user: user, trail: trail} do
      assert Common.approved() == Abilities.can?(user, :list, trail)
    end

    test "cannot create trails", %{user: user, trail: trail} do
      assert Common.no_access_permission() == Abilities.can?(user, :create, trail)
    end
  end

  describe "a user with only create permission" do
    setup [:create_trail, :user_with_create_permission]

    test "can read a trail", %{user: user, trail: trail} do
      assert Common.approved() == Abilities.can?(user, :read, trail)
    end

    test "cannot write a trail", %{user: user, trail: trail} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :write, trail)
    end

    test "cannot delete a trail", %{user: user, trail: trail} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :delete, trail)
    end

    test "can list trails", %{user: user, trail: trail} do
      assert Common.approved() == Abilities.can?(user, :list, trail)
    end

    test "can create trails", %{user: user, trail: trail} do
      assert Common.approved() == Abilities.can?(user, :create, trail)
    end
  end

  describe "a user with only delete permission" do
    setup [:create_trail, :user_with_delete_permission]

    test "can read a trail", %{user: user, trail: trail} do
      assert Common.approved() == Abilities.can?(user, :read, trail)
    end

    test "cannot write a trail", %{user: user, trail: trail} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :write, trail)
    end

    test "can delete a trail", %{user: user, trail: trail} do
      assert Common.approved() == Abilities.can?(user, :delete, trail)
    end

    test "can list trails", %{user: user, trail: trail} do
      assert Common.approved() == Abilities.can?(user, :list, trail)
    end

    test "cannot create trails", %{user: user, trail: trail} do
      assert Common.no_access_permission() == Abilities.can?(user, :create, trail)
    end
  end

  describe "a user with only list permission" do
    setup [:create_trail, :user_with_list_permission]

    test "can read a trail", %{user: user, trail: trail} do
      assert Common.approved() == Abilities.can?(user, :read, trail)
    end

    test "cannot write a trail", %{user: user, trail: trail} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :write, trail)
    end

    test "cannot delete a trail", %{user: user, trail: trail} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :delete, trail)
    end

    test "can list trails", %{user: user, trail: trail} do
      assert Common.approved() == Abilities.can?(user, :list, trail)
    end

    test "cannot create trails", %{user: user, trail: trail} do
      assert Common.no_access_permission() == Abilities.can?(user, :create, trail)
    end
  end

  describe "a user with no permission" do
    setup [:create_trail, :user_with_no_permission]

    test "can read a trail", %{user: user, trail: trail} do
      assert Common.approved() == Abilities.can?(user, :read, trail)
    end

    test "cannot write a trail", %{user: user, trail: trail} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :write, trail)
    end

    test "cannot delete a trail", %{user: user, trail: trail} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :delete, trail)
    end

    test "can list trails", %{user: user, trail: trail} do
      assert Common.approved() == Abilities.can?(user, :list, trail)
    end

    test "cannot create trails", %{user: user, trail: trail} do
      assert Common.no_access_permission() == Abilities.can?(user, :create, trail)
    end
  end

  describe "a user with invalid permission" do
    setup [:create_trail, :user_with_invalid_permission]

    test "can read a trail", %{user: user, trail: trail} do
      assert Common.approved() == Abilities.can?(user, :read, trail)
    end

    test "cannot write a trail", %{user: user, trail: trail} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :write, trail)
    end

    test "cannot delete a trail", %{user: user, trail: trail} do
      assert Abilities.no_instance_permission() == Abilities.can?(user, :delete, trail)
    end

    test "can list trails", %{user: user, trail: trail} do
      assert Common.approved() == Abilities.can?(user, :list, trail)
    end

    test "cannot create trails", %{user: user, trail: trail} do
      assert Common.no_access_permission() == Abilities.can?(user, :create, trail)
    end
  end
end
