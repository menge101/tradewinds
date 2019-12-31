defmodule Tradewinds.Fixtures.Event do
  @moduledoc false

  alias Tradewinds.Accounts
  alias Tradewinds.Events
  alias Tradewinds.Events.Event
  alias Tradewinds.Fixtures.User, as: UserFixture

  @admin_attrs [
    %{
      auth0_id: "admin1 auth0_id",
      name: "admin1 name",
      email: "admin1@email.com",
      permissions: %{},
      creator: "exunit tests"
    },
    %{
      auth0_id: "admin2 auth0_id",
      name: "admin2 name",
      email: "admin2@email.com",
      permissions: %{},
      creator: "exunit tests"
    }
  ]
  @creator_attrs %{
    auth0_id: "creator auth0_id",
    name: "some name",
    email: "creator@email.com",
    permissions: %{},
    creator: "exunit tests"
  }
  @user_attrs %{
    auth0_id: "an event user auth0_id",
    name: "some name",
    email: "some@email.com",
    permissions: %{},
    admins: [],
    creator: "exunit tests"
  }
  @update_attrs %{
    description: "some updated description",
    end: "2011-05-18T15:01:01Z",
    hosting_kennel: "some updated hosting_kennel",
    latitude: 456.7,
    location: "some updated location",
    longitude: 456.7,
    name: "some updated name",
    start: "2011-05-18T15:01:01Z"
  }
  @invalid_attrs %{
    description: nil,
    end: nil,
    hosting_kennel: nil,
    latitude: nil,
    location: nil,
    longitude: nil,
    name: nil,
    start: nil,
    admins: nil,
    creator: nil
  }

  def add_admins(attrs) do
    Enum.reduce(@admin_attrs, attrs,
      fn (admin, acc) ->
        admins = [create_user_unless_exists(admin).id | Map.get(acc, :admins, [])]
        Map.put(acc, :admins, admins)
      end
    )
  end

  def add_creator(attrs) do
    Map.put(attrs, :creator, create_user_unless_exists(@creator_attrs).id)
  end

  def add_fake_ids(attrs), do: Map.merge(%{creator: 7, admins: [3, 4]}, attrs)

  def create_attrs(overloads \\ %{}, persist \\ true) do
    attrs = overloads
    |> Map.merge(%{
      description: "some description",
      name: "some name",
      start: ~U[2100-04-17 14:00:00Z],
      end: ~U[2100-04-19 14:00:00Z],
      hosting_kennel: "some kennel",
      latitude: 0.00,
      longitude: 0.00,
      location: "a location"
    },
         fn (_, v1, _) -> v1 end)
    if persist do
      attrs
      |> add_creator
      |> add_admins
    else
      add_fake_ids(attrs)
    end
  end

  def create_user(perms, persist \\ true) do
    fixture(:user, @user_attrs, persist)
    |> elem(1)
    |> Map.put(:permissions, perms)
    |> (fn user -> {:ok, user: user} end).()
  end

  def fixture(atom, attrs \\ %{}, persist \\ false)
  def fixture(:event, attrs, persist) do
    attrs = create_attrs(attrs, persist)
    if persist do
      attrs
      |> Events.create_event
      |> elem(1)
      |> (fn event -> {:ok, event: event} end).()
    else
      attrs
      |> (fn event -> {:ok, event: struct(Event, event)} end).()
    end
  end

  def fixture(:user, attrs, _) do
    attrs
    |> Map.merge(@user_attrs, fn (_, v1, _) -> v1 end)
    |> Accounts.create_user
  end

  def invalid_attrs do
    @invalid_attrs
  end

  def permission_list do
    [:read, :write, :delete, :list, :create]
  end

  def update_attrs do
    create_attrs(@update_attrs)
  end

  def user_with_all_permission(_) do
    UserFixture.create_user(%{event: permission_list()})
  end

  def user_with_no_permission(_) do
    UserFixture.create_user(%{event: []})
  end

  def user_with_read_permission(_) do
    UserFixture.create_user(%{event: [:read]})
  end

  def user_with_write_permission(_) do
    UserFixture.create_user(%{event: [:write]})
  end

  def user_with_list_permission(_) do
    UserFixture.create_user(%{event: [:list]})
  end

  def user_with_delete_permission(_) do
    UserFixture.create_user(%{event: [:delete]})
  end

  def user_with_create_permission(_) do
    UserFixture.create_user(%{event: [:create]})
  end

  def user_with_invalid_permission(_) do
    UserFixture.create_user(%{event: [:hash]})
  end

  def admin_with_no_permission(_) do
    UserFixture.create_user(%{event: []}, %{id: 4})
  end

  def admin_with_invalid_permission(_) do
    UserFixture.create_user(%{event: [:hash]}, %{id: 4})
  end

  defp create_user_unless_exists(%{auth0_id: auth0_id} = attrs) do
    case Accounts.get_user(%{auth0_id: auth0_id}) do
      {:ok, user} -> user
      {:error, _} ->
        {:ok, user} = Accounts.create_user(attrs)
        user
    end
  end
end
