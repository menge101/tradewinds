defmodule Tradewinds.Tests.User do
  use Tradewinds.DataCase

  alias Tradewinds.Accounts.User
  alias Tradewinds.Fixtures.User, as: UserFix

  @all_fields [:id, :name, :permissions, :avatar_link, :email, :kennel, :creator]

  describe "User struct" do
    test "can be created" do
      actual = UserFix.create_user(%{})
      |> elem(1)
      |> Keyword.get(:user)
      expected = %Tradewinds.Accounts.User{
        avatar_link: "https://someline.com",
        creator: "exunit tests",
        email: "some@email.com",
        id: "an auth0_id",
        kennel: %{
          acronym: "TKH3",
          geostring: "europe#balkans#greece#pelopennesia#sparta",
          name: "Test Kennel"
        },
        name: %{
          first: "John",
          hash: "Something vaguely crass",
          last: "Crass"
        },
        permissions: %{}
      }
      assert actual == expected
    end

    test "a User Struct can be cast" do
      cast = UserFix.create_user(%{})
      |> elem(1)
      |> Keyword.get(:user)
      |> User.cast(%{}, @all_fields)
      assert %{data: %{avatar_link: "https://someline.com",
                       creator: "exunit tests",
                       email: "some@email.com",
                       id: "an auth0_id",
                       permissions: %{},
                       name: %{first: "John", hash: "Something vaguely crass", last: "Crass"},
                       kennel: %{acronym: "TKH3", name: "Test Kennel",
                         geostring: "europe#balkans#greece#pelopennesia#sparta"}},
               errors: []} == cast
    end

    test "required fields can be validated" do
      error_set = %{
        data: %{},
        errors: [
          "Key id is required",
          "Key name is required",
          "Key permissions is required",
          "Key avatar_link is required",
          "Key email is required",
          "Key kennel is required",
          "Key creator is required"
        ]
      }
      %{data: %{}, errors: []}
      |> User.validate_required(@all_fields)
      |> (fn (observed, expected) ->
            assert (expected == observed)
          end).(error_set)
    end

    test "fields can be validated as non-nil" do
      error_set = ["Key id cannot be nil", "Key name cannot be nil", "Key permissions cannot be nil",
        "Key avatar_link cannot be nil", "Key email cannot be nil", "Key kennel cannot be nil",
        "Key creator cannot be nil"]
      %{data: %{}, errors: []}
      |> User.validate_not_nil(@all_fields)
      |> Map.get(:errors)
      |> (fn (observed, expected) ->
            assert (expected == observed)
          end).(error_set)
    end

    test "kennel map can be verified for non-existent key" do
      expected = ["Key kennel is required to exist and be non-nil"]
      %{data: %{}, errors: []}
      |> User.validate_kennel()
      |> Map.get(:errors)
      |> (fn (observed, expected) -> assert (expected == observed) end).(expected)
    end

    test "kennel map can be verified" do
      expected = ["Kennel map requires key [:kennel][name] to exist and be non-nil",
        "Kennel map requires key [:kennel][acronym] to exist and be non-nil",
        "Kennel map requires key [:kennel][geostring] to exist and be non-nil"]
      %{data: %{kennel: %{}}, errors: []}
      |> User.validate_kennel()
      |> Map.get(:errors)
      |> (fn (observed, expected) -> assert (expected == observed) end).(expected)
    end

    test "name map can be verified for non-existent key" do
      expected = ["Key name is required to exist and be non-nil"]
      %{data: %{}, errors: []}
      |> User.validate_name()
      |> Map.get(:errors)
      |> (fn (observed, expected) -> assert (expected == observed) end).(expected)
    end

    test "name map can be verified" do
      expected = ["Name map requires key [name][hash] to exist and be non-nil",
        "Name map requires key [name][first] to exist and be non-nil",
        "Name map requires key [name][last] to exist and be non-nil"]
      %{data: %{name: %{}}, errors: []}
      |> User.validate_name()
      |> Map.get(:errors)
      |> (fn (observed, expected) -> assert (expected == observed) end).(expected)
    end

    test "a changeset can be created from a User struct" do
      assert %{data: %{}, errors: []} = UserFix.create_user(%{})
                                        |> elem(1)
                                        |> Keyword.get(:user)
                                        |> User.changeset(%{})
    end

    test "a changeset can be converted to a generic map" do
      assert %{data: %{}, errors: [], generic: %{}} = UserFix.create_user(%{})
                                                      |> elem(1)
                                                      |> Keyword.get(:user)
                                                      |> User.changeset(%{})
                                                      |> User.to_generic()

    end
  end
end