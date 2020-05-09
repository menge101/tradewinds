defmodule Tradewinds.Dynamo.Changeset.Tests do
  @moduledoc """
  This module tests the Changeset module.
"""

  use Tradewinds.DataCase

  alias Tradewinds.Accounts.User
  alias Tradewinds.Dynamo.Changeset

  describe "Changesets" do
    test "Changeset is a struct with errors, changes, and original keys" do
      assert %_{} = %Changeset{}
      # Struct's have a special key :__struct__ to seperate them from Maps, which is accounted for here
      assert Enum.sort(Map.keys(%Changeset{})) == Enum.sort([:__struct__, :errors, :changes, :original])
    end

    test "a Changeset is created by casting a struct with a changemap together" do
      test_user = %User{pk: "1", sk: "2", names: %{a: "aye"}, permissions: %{}, email: "3", presentation: %{b: "bee"}}
      changes = %{names: %{c: "sea"}, email: "4"}
      actual = Changeset.cast(test_user, changes, [:pk, :sk, :names, :permissions, :email, :presentation])
      changes = Map.from_struct(test_user)
      |> Map.merge(changes)
      expected = %Changeset{errors: [], original: Map.from_struct(test_user), changes: changes}
      assert actual == expected
    end
  end
end