defmodule Tradewinds.Tests.User do
  use Tradewinds.DataCase

  alias Tradewinds.Accounts.User
  alias Tradewinds.Dynamo.Changeset
  alias Tradewinds.Fixtures.User, as: UserFix
  alias Tradewinds.Helpers.Structs

  @all_fields Structs.keys(%User{})

  describe "User struct" do
    test "can be created" do
      actual = UserFix.create_user(%{})
      |> elem(1)
      |> Keyword.get(:user)
      expected = %Tradewinds.Accounts.User{
        email: "some@email.com",
        names: %{
          first: "John",
          hash: "Something vaguely crass",
          last: "Crass"
        },
        permissions: %{},
        pk: "an auth0 id",
        presentation: %{avatar_link: "https://some.url/image.png", hash_name: "Something vaguely crass"},
        sk: "user_details"
      }
      assert actual == expected
    end

    test "required fields can be validated" do
      expected = %Changeset{
        changes: %{email: nil, names: nil, permissions: nil, pk: nil, presentation: nil, sk: nil},
        errors: [
          "Key email is required",
          "Key names is required",
          "Key permissions is required",
          "Key pk is required",
          "Key presentation is required",
          "Key sk is required"
        ],
        original: %{email: nil, names: nil, permissions: nil, pk: nil, presentation: nil, sk: nil}
      }
      cs = Changeset.cast(%User{}, %{}, @all_fields)
      |> User.validate_required(@all_fields)
      assert cs == expected
    end

    test "fields can be validated as non-nil" do
      error_set = ["Key email cannot be nil",
        "Key names cannot be nil",
        "Key permissions cannot be nil",
        "Key pk cannot be nil",
        "Key presentation cannot be nil",
        "Key sk cannot be nil"]
      Changeset.cast(%User{}, %{}, @all_fields)
      |> User.validate_not_nil(@all_fields)
      |> Map.get(:errors)
      |> (fn (observed, expected) ->
            assert (expected == observed)
          end).(error_set)
    end

    test "name map can be verified for non-existent key" do
      expected = %Changeset{
        changes: %{email: nil, names: nil, permissions: nil, pk: nil, presentation: nil, sk: nil},
        errors: ["Key 'names' is required to exist and be non-nil"],
        original: %{email: nil, names: nil, permissions: nil, pk: nil, presentation: nil, sk: nil}
      }
      cs = Changeset.cast(%User{}, %{}, @all_fields)
           |> User.validate_names()
      assert cs == expected
    end

    test "name map can be verified" do
      expected = %Changeset{
        changes: %{email: nil, names: %{}, permissions: nil, pk: nil, presentation: nil, sk: nil},
        errors: [
          "Name map requires key [name][first] to exist and be non-nil",
          "Name map requires key [name][last] to exist and be non-nil",
          "Name map requires key [name][hash] to exist and be non-nil"
        ],
        original: %{email: nil, names: nil, permissions: nil, pk: nil, presentation: nil, sk: nil}
      }

      cs = Changeset.cast(%User{}, %{names: %{}}, @all_fields)
           |> User.validate_names()
      assert cs == expected
    end
  end
end