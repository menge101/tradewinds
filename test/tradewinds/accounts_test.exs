defmodule Tradewinds.AccountsTest do
  use Tradewinds.DataCase

  alias Tradewinds.Accounts
  alias Tradewinds.Fixtures.User, as: UserFix
  alias Tradewinds.Dynamo.Changeset
  alias Tradewinds.Dynamo.Repo
  alias Tradewinds.Dynamo.Table
  alias Tradewinds.Test.Support.Compare

  describe "users" do
    alias Tradewinds.Accounts.User
    setup [:create_table]

    test "get_user/1 returns the user with given id" do
      {:ok, %User{pk: pk} = user} = Accounts.create_user(UserFix.user_attrs())
      assert user == Accounts.get_user(pk)
    end

    test "create_user/1 with valid data creates a user" do
      {:ok, %User{pk: pk, sk: sk} = user} = Accounts.create_user(UserFix.user_attrs())
      %{"pk" => _, "sk" => "user_details", "record_type" => "user_details"} = Repo.get(%{pk: pk, sk: sk})
    end

    test "create_user/1 with a primary hash key creates a user" do
      {:ok, %User{pk: pk, sk: sk} = user} = Accounts.create_user(UserFix.user_attrs(%{pk: "testing-id"}))
      %{"pk" => _, "sk" => "user_details", "record_type" => "user_details"} = Repo.get(%{pk: pk, sk: sk})
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Changeset{changes: %{pk: pk, sk: sk}}} = Accounts.create_user(UserFix.invalid_attrs())
      assert pk == nil
      assert sk == "user_details"
    end

    test "create_user/1 with invalid data with valid names returns error changeset" do
      user = Accounts.create_user(UserFix.invalid_attrs(%{names: %{first: "hi", last: "ho", hash: "here we go"}}))
      {:error, %Changeset{changes: %{pk: pk, sk: sk}}} = user
      assert %{} == Repo.get(%{pk: pk, sk: sk})
    end

    test "update_user/2 with valid data updates the user" do
      {:ok, user} = Accounts.create_user(UserFix.user_attrs())
      assert {:ok, %User{} = user} = Accounts.update_user(user, %{a: "aye"})
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
    table_def = Application.fetch_env!(:tradewinds, :dynamodb)[:table]
    %{name: table_name} = table_def
    Table.create(table_def)

    on_exit fn ->
      Table.delete(table_name)
    end
  end
end
