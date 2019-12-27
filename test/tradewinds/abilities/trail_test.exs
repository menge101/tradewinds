defmodule Tradewinds.Abilities.TrailsTest do
  use Tradewinds.DataCase
  import Tradewinds.Fixtures.Trail
  import Tradewinds.Fixtures.Common
  alias Tradewinds.Trails.Trail.Abilities

  describe "a trail in the past" do
    setup [:create_old_trail, :user_with_all_permission]

    test "can be read", %{user: user, trail: trail} do
      assert success() == Abilities.can?(user, :read, trail)
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
      assert success() == Abilities.can?(user, :read, trail)
    end

    test "cannot write a trail", %{user: user, trail: trail} do
      assert no_instance_permission() == Abilities.can?(user, :write, trail)
    end

    test "cannot delete a trail", %{user: user, trail: trail} do
      assert no_instance_permission() == Abilities.can?(user, :delete, trail)
    end

    test "can list trails", %{user: user, trail: trail} do
      assert success() == Abilities.can?(user, :list, trail)
    end

    test "cannot create trails", %{user: user, trail: trail} do
      assert no_access_permission() == Abilities.can?(user, :create, trail)
    end
  end

  describe "a user with only write permission" do
    setup [:create_trail, :user_with_write_permission]

    test "can read a trail", %{user: user, trail: trail} do
      assert success() == Abilities.can?(user, :read, trail)
    end

    test "can write a trail", %{user: user, trail: trail} do
      assert success() == Abilities.can?(user, :write, trail)
    end

    test "cannot delete a trail", %{user: user, trail: trail} do
      assert no_instance_permission() == Abilities.can?(user, :delete, trail)
    end

    test "can list trails", %{user: user, trail: trail} do
      assert success() == Abilities.can?(user, :list, trail)
    end

    test "cannot create trails", %{user: user, trail: trail} do
      assert no_access_permission() == Abilities.can?(user, :create, trail)
    end
  end

  describe "a user with only create permission" do
    setup [:create_trail, :user_with_create_permission]

    test "can read a trail", %{user: user, trail: trail} do
      assert success() == Abilities.can?(user, :read, trail)
    end

    test "cannot write a trail", %{user: user, trail: trail} do
      assert no_instance_permission() == Abilities.can?(user, :write, trail)
    end

    test "cannot delete a trail", %{user: user, trail: trail} do
      assert no_instance_permission() == Abilities.can?(user, :delete, trail)
    end

    test "can list trails", %{user: user, trail: trail} do
      assert success() == Abilities.can?(user, :list, trail)
    end

    test "can create trails", %{user: user, trail: trail} do
      assert success() == Abilities.can?(user, :create, trail)
    end
  end

  describe "a user with only delete permission" do
    setup [:create_trail, :user_with_delete_permission]

    test "can read a trail", %{user: user, trail: trail} do
      assert success() == Abilities.can?(user, :read, trail)
    end

    test "cannot write a trail", %{user: user, trail: trail} do
      assert no_instance_permission() == Abilities.can?(user, :write, trail)
    end

    test "can delete a trail", %{user: user, trail: trail} do
      assert success() == Abilities.can?(user, :delete, trail)
    end

    test "can list trails", %{user: user, trail: trail} do
      assert success() == Abilities.can?(user, :list, trail)
    end

    test "cannot create trails", %{user: user, trail: trail} do
      assert no_access_permission() == Abilities.can?(user, :create, trail)
    end
  end

  describe "a user with only list permission" do
    setup [:create_trail, :user_with_list_permission]

    test "can read a trail", %{user: user, trail: trail} do
      assert success() == Abilities.can?(user, :read, trail)
    end

    test "cannot write a trail", %{user: user, trail: trail} do
      assert no_instance_permission() == Abilities.can?(user, :write, trail)
    end

    test "cannot delete a trail", %{user: user, trail: trail} do
      assert no_instance_permission() == Abilities.can?(user, :delete, trail)
    end

    test "can list trails", %{user: user, trail: trail} do
      assert success() == Abilities.can?(user, :list, trail)
    end

    test "cannot create trails", %{user: user, trail: trail} do
      assert no_access_permission() == Abilities.can?(user, :create, trail)
    end
  end

  describe "a user with no permission" do
    setup [:create_trail, :user_with_no_permission]

    test "can read a trail", %{user: user, trail: trail} do
      assert success() == Abilities.can?(user, :read, trail)
    end

    test "cannot write a trail", %{user: user, trail: trail} do
      assert no_instance_permission() == Abilities.can?(user, :write, trail)
    end

    test "cannot delete a trail", %{user: user, trail: trail} do
      assert no_instance_permission() == Abilities.can?(user, :delete, trail)
    end

    test "can list trails", %{user: user, trail: trail} do
      assert success() == Abilities.can?(user, :list, trail)
    end

    test "cannot create trails", %{user: user, trail: trail} do
      assert no_access_permission() == Abilities.can?(user, :create, trail)
    end
  end

  describe "a user with invalid permission" do
    setup [:create_trail, :user_with_invalid_permission]

    test "can read a trail", %{user: user, trail: trail} do
      assert success() == Abilities.can?(user, :read, trail)
    end

    test "cannot write a trail", %{user: user, trail: trail} do
      assert no_instance_permission() == Abilities.can?(user, :write, trail)
    end

    test "cannot delete a trail", %{user: user, trail: trail} do
      assert no_instance_permission() == Abilities.can?(user, :delete, trail)
    end

    test "can list trails", %{user: user, trail: trail} do
      assert success() == Abilities.can?(user, :list, trail)
    end

    test "cannot create trails", %{user: user, trail: trail} do
      assert no_access_permission() == Abilities.can?(user, :create, trail)
    end
  end

  describe "an owner with no permissions" do
    setup do
      {:ok, owner} = User.create_user(%{}, %{id: 5})
      {:ok, trail} = create_trail(%{})
      {:ok, Enum.concat(owner, trail)}
    end

    test "can read an owned trail", %{user: user, trail: trail} do
      assert success() == Abilities.can?(user, :read, trail)
    end

    test "cannot write an owned trail", %{user: user, trail: trail} do
      assert success() == Abilities.can?(user, :write, trail)
    end

    test "can delete an owned trail", %{user: user, trail: trail} do
      assert success() == Abilities.can?(user, :delete, trail)
    end

    test "can list trails", %{user: user, trail: trail} do
      assert success() == Abilities.can?(user, :list, trail)
    end

    test "cannot create trails", %{user: user, trail: trail} do
      assert no_access_permission() == Abilities.can?(user, :create, trail)
    end
  end
end
