defmodule Tradewinds.AccountsTest do
  use Tradewinds.DataCase

  alias Tradewinds.Accounts
  alias Tradewinds.Fixtures.User, as: UserFix
  alias Tradewinds.Dynamo.Table

  describe "users" do
    alias Tradewinds.Accounts.User
    setup [:create_table]

    test "list_users/0 returns all users" do
      user = UserFix.create_user(%{})
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = UserFix.create_user(%{})
      |> elem(1)
      |> Keyword.get(:user)
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %{}} == Accounts.create_user(UserFix.user_attrs())
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user("")
    end

    test "update_user/2 with valid data updates the user" do
      user = UserFix.create_users(%{})
      assert {:ok, %User{} = user} = Accounts.update_user(user, "")
      assert user.auth0_id == "some updated auth0_id"
      assert user.name == "some updated name"
      assert user.permissions == %{}
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = UserFix.create_users(%{})
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, UserFix.invalid_attrs())
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = UserFix.create_users(%{})
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = UserFix.create_users(%{})
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "registrations" do
    alias Tradewinds.Accounts.Registration
    alias Tradewinds.Fixtures.Registration, as: RegoFix

    @event_attrs %{
      description: "some updated description",
      end: "2011-05-18T15:01:01Z",
      hosting_kennel: "some updated hosting_kennel",
      latitude: 456.7,
      location: "some updated location",
      longitude: 456.7,
      name: "some updated name",
      start: "2011-05-18T15:01:01Z"
    }
    @valid_attrs %{selection: %{}, event: @event_attrs}
    @update_attrs %{selection: %{"a" => 1, "b" => 2}}
    @invalid_attrs %{selection: nil, event: nil}

    test "list_registrations/0 returns all registrations" do
      {:ok, [registration: registration]} = RegoFix.fixture(:registration, %{}, true)
      assert Accounts.list_registrations()
      |> Enum.map(fn rego -> Repo.preload(rego, [:event, :user] ) end)
      |> (fn enum -> apply(Kernel, :==, [enum, [registration]]) end).()
    end

    test "get_registration!/1 returns the registration with given id" do
      {:ok, [registration: registration]} = RegoFix.fixture(:registration, %{}, true)
      assert Accounts.get_registration!(registration.id)
      |> Repo.preload([:event, :user])
      |> (fn rego -> apply(Kernel, :==, [rego, registration]) end).()
    end

    test "create_registration/1 with valid data creates a registration" do
      rego_response = Accounts.create_registration(RegoFix.create_attrs(@valid_attrs, true))
      assert {:ok, %Registration{} = registration} = rego_response
      assert registration.selection == %{}
    end

    test "create_registration/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_registration(RegoFix.create_attrs(@invalid_attrs))
    end

    test "update_registration/2 with valid data updates the registration" do
      registration = RegoFix.fixture(:registration, %{}, true)
      |> elem(1)
      |> Keyword.get(:registration)

      update_attrs = registration
      |> Map.from_struct()
      |> Map.delete(:__meta__)
      |> Map.merge(@update_attrs)

      assert {:ok, %Registration{} = registration} = Accounts.update_registration(registration, update_attrs)
      assert Accounts.get_registration!(registration.id).selection == @update_attrs.selection
    end

    test "update_registration/2 with invalid data returns error changeset" do
      {:ok, [registration: registration]} = RegoFix.fixture(:registration, %{}, true)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_registration(registration, @invalid_attrs)
      Accounts.get_registration!(registration.id)
      |> Repo.preload([:event, :user])
      |> (fn rego -> apply(Kernel, :==, [registration, rego]) end).()
    end

    test "delete_registration/1 deletes the registration" do
      {:ok, [registration: registration]} = RegoFix.fixture(:registration, %{}, true)
      assert {:ok, %Registration{}} = Accounts.delete_registration(registration)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_registration!(registration.id) end
    end

    test "change_registration/1 returns a registration changeset" do
      {:ok, [registration: registration]} = RegoFix.fixture(:registration, %{}, true)
      assert %Ecto.Changeset{} = Accounts.change_registration(registration)
    end
  end

  def create_table(_) do
    [tablename: table_name] = Application.get_env(:tradewinds, :dynamodb, :tablename)
    key_schema = [%{"attribute_name" => "pk_gs1sk_gs2sk", "attribute_type" => "string", "key_type" => "HASH"},
                  %{"attribute_name" => "sk_gs1pk", "attribute_type" => "string", "key_type" => "RANGE"}]
    global_indexes = [%{"index_name" => "gs1", "projection" => %{"projection_type" => "ALL"},
                        "key_schema" => [%{"attribute_name" => "gs2pk", "key_type" => "HASH"},
                                         %{"attribute_name" => "pk_gs1sk_gs2sk", "key_type" => "RANGE"}]},
                      %{"index_name" => "gs2", "projection" => %{"projection_type" => "ALL"},
                        "key_schema" => [%{"attribute_name" => "gs2pk", "key_type" => "HASH"},
                                         %{"attribute_name" => "pk_gs1sk_gs2sk", "key_type" => "RANGE"}]}]
    Table.create(table_name, key_schema, global_indexes, [], 1, 1, :pay_per_request)
    IO.puts "Table: #{table_name} created"

    on_exit fn ->
      Table.delete(table_name)
    end
  end
end
