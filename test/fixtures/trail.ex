defmodule Tradewinds.Fixtures.Trail do
  @moduledoc false

  alias Tradewinds.Accounts.User, as: User
  alias Tradewinds.Fixtures.User, as: UserFixture
  alias Tradewinds.Trails.Trail

  def creator_attrs(overloads \\ %{}) do
    UserFixture.user_attrs(
      Map.merge(
        %{
          auth0_id: "creator auth0_id",
          name: "some name",
          email: "creator@email.com",
          permissions: %{},
          creator: "exunit tests"
        }, overloads
      )
    )
  end

  def create_attrs(overloads \\ %{}) do
    overloads
    |> Map.merge(%{
          description: "some description",
          name: "some name",
          start: ~U[2100-04-17 14:00:00Z],
          owners: [5, 6],
          creator: 7
        },
        fn (_, v1, _) -> v1 end)
  end

  def old_attrs(overloads \\ %{}) do
    overloads
    |> (fn (dom_map, other_map) -> Map.merge(other_map, dom_map) end).(%{start: ~U[2001-04-17 14:00:00Z]})
    |> create_attrs
  end

  def no_instance_permission do
    {:error, "Current user does not have permission to perform this action on this trail."}
  end

  def cannot_change_history do
    {:error, "Historic records are not editable"}
  end

  def fixture(atom, attrs \\ %{})
  def fixture(:trail, attrs) do
    attrs
    |> (fn (precedent_map, other_map) -> Map.merge(other_map, precedent_map) end).(create_attrs())
    |> (fn (attrs, struct) -> struct(struct, attrs) end).(%Trail{})
  end

  def fixture(:creator, _) do
    UserFixture.user_attrs
    |> (fn (attrs, struct) -> struct(struct, attrs) end).(%User{})
  end

  def user_with_all_permission(_) do
    UserFixture.create_user(%{trail: TradewindsWeb.TrailController.permission_list})
  end

  def user_with_no_permission(_) do
    UserFixture.create_user(%{trail: []})
  end

  def user_with_read_permission(_) do
    UserFixture.create_user(%{trail: [:read]})
  end

  def user_with_write_permission(_) do
    UserFixture.create_user(%{trail: [:write]})
  end

  def user_with_list_permission(_) do
    UserFixture.create_user(%{trail: [:list]})
  end

  def user_with_delete_permission(_) do
    UserFixture.create_user(%{trail: [:delete]})
  end

  def user_with_create_permission(_) do
    UserFixture.create_user(%{trail: [:create]})
  end

  def user_with_invalid_permission(_) do
    UserFixture.create_user(%{trail: [:hash]})
  end

  def create_trail(_) do
    {:ok, trail: fixture(:trail, create_attrs())}
  end

  def create_old_trail(_) do
    {:ok, trail: fixture(:trail, old_attrs())}
  end
end
