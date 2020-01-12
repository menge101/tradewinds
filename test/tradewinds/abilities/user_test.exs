defmodule Tradewinds.Abilities.UserTest do
  use Tradewinds.DataCase
  import Tradewinds.Fixtures.User

  alias Tradewinds.Abilities.Common
  alias Tradewinds.Accounts.User
  alias Tradewinds.Accounts.User.Abilities

  describe "current user with only read permission" do
    setup do
      {:ok, current_user_list} = current_user(%{user: [:read]})
      {:ok, target_user_list} = create_user(%{})
      {:ok, Enum.concat(current_user_list, target_user_list) }
    end

    test "can read target user", %{current_user: current, user: target} do
      assert Common.approved() == Abilities.can?(current, :read, target)
    end

    test "cannot write target user", %{current_user: current, user: target} do
      assert no_instance_permission() == Abilities.can?(current, :write, target)
    end

    test "cannot delete target user", %{current_user: current, user: target} do
      assert no_instance_permission() == Abilities.can?(current, :delete, target)
    end

    test "cannot list users", %{current_user: current} do
      assert Common.no_access_permission() == Abilities.can?(current, :list)
    end

    test "cannot create a user", %{current_user: current} do
      assert Common.no_access_permission() == Abilities.can?(current, :create)
    end
  end

  describe "current user with only write permission" do
    setup do
      {:ok, current_user_list} = current_user(%{user: [:write]})
      {:ok, target_user_list} = create_user(%{})
      {:ok, Enum.concat(current_user_list, target_user_list) }
    end

    test "cannot read target user", %{current_user: current, user: target} do
      assert no_instance_permission() == Abilities.can?(current, :read, target)
    end

    test "can write target user", %{current_user: current, user: target} do
      assert Common.approved() == Abilities.can?(current, :write, target)
    end

    test "cannot delete target user", %{current_user: current, user: target} do
      assert no_instance_permission() == Abilities.can?(current, :delete, target)
    end

    test "cannot list users", %{current_user: current} do
      assert Common.no_access_permission() == Abilities.can?(current, :list)
    end

    test "cannot create a user", %{current_user: current} do
      assert Common.no_access_permission() == Abilities.can?(current, :create)
    end
  end

  describe "current user with only delete permission" do
    setup do
      {:ok, current_user_list} = current_user(%{user: [:delete]})
      {:ok, target_user_list} = create_user(%{})
      {:ok, Enum.concat(current_user_list, target_user_list) }
    end

    test "cannot read target user", %{current_user: current, user: target} do
      assert no_instance_permission() == Abilities.can?(current, :read, target)
    end

    test "cannot write target user", %{current_user: current, user: target} do
      assert no_instance_permission() == Abilities.can?(current, :write, target)
    end

    test "can delete target user", %{current_user: current, user: target} do
      assert Common.approved() == Abilities.can?(current, :delete, target)
    end

    test "cannot list users", %{current_user: current} do
      assert Common.no_access_permission() == Abilities.can?(current, :list)
    end

    test "cannot create a user", %{current_user: current} do
      assert Common.no_access_permission() == Abilities.can?(current, :create)
    end
  end

  describe "current user with only list permission" do
    setup do
      {:ok, current_user_list} = current_user(%{user: [:list]})
      {:ok, target_user_list} = create_user(%{})
      {:ok, Enum.concat(current_user_list, target_user_list) }
    end

    test "cannot read target user", %{current_user: current, user: target} do
      assert no_instance_permission() == Abilities.can?(current, :read, target)
    end

    test "cannot write target user", %{current_user: current, user: target} do
      assert no_instance_permission() == Abilities.can?(current, :write, target)
    end

    test "cannot delete target user", %{current_user: current, user: target} do
      assert no_instance_permission() == Abilities.can?(current, :delete, target)
    end

    test "can list users", %{current_user: current} do
      assert Common.approved() == Abilities.can?(current, :list)
    end

    test "cannot create a user", %{current_user: current} do
      assert Common.no_access_permission() == Abilities.can?(current, :create)
    end
  end

  describe "current user with only create permission" do
    setup do
      {:ok, current_user_list} = current_user(%{user: [:create]})
      {:ok, target_user_list} = create_user(%{})
      {:ok, Enum.concat(current_user_list, target_user_list) }
    end

    test "cannot read target user", %{current_user: current, user: target} do
      assert no_instance_permission() == Abilities.can?(current, :read, target)
    end

    test "cannot write target user", %{current_user: current, user: target} do
      assert no_instance_permission() == Abilities.can?(current, :write, target)
    end

    test "cannot delete target user", %{current_user: current, user: target} do
      assert no_instance_permission() == Abilities.can?(current, :delete, target)
    end

    test "cannot list users", %{current_user: current} do
      assert Common.no_access_permission() == Abilities.can?(current, :list)
    end

    test "can create a user", %{current_user: current} do
      assert Common.approved() == Abilities.can?(current, :create)
    end
  end

  describe "calling functions with wrong type" do
    setup do
      {:ok, current_user_list} = current_user(%{user: [:create]})
      {:ok, target_user_list} = create_user(%{})
      {:ok, Enum.concat(current_user_list, target_user_list) }
    end

    test "calling read with User module", %{current_user: current} do
      assert catch_error(Abilities.can?(current, :read, User))
    end

    test "calling write with User module", %{current_user: current} do
      assert catch_error(Abilities.can?(current, :write, User))
    end

    test "calling delete with User module", %{current_user: current} do
      assert catch_error(Abilities.can?(current, :delete, User))
    end

    test "calling list with User struct", %{current_user: current, user: target} do
      assert catch_error(Abilities.can?(current, :list, target))
    end

    test "calling create with User struct", %{current_user: current, user: target} do
      assert catch_error(Abilities.can?(current, :create, target))
    end
  end
end
