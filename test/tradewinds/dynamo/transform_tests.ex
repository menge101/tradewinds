defmodule Tradewinds.Dynamo.Changeset.Transform.Tests do
  @moduledoc """
  Home of tests for CHangeset transforms.
"""
  use Tradewinds.DataCase

  alias Tradewinds.Accounts.User
  alias Tradewinds.Dynamo.Changeset
  alias Tradewinds.Dynamo.Changeset.Transform
  alias Tradewinds.Dynamo.Record

  describe "Changeset transform" do
    test "can find the constraint set from a changeset" do
      test_user = %User{pk: "1", sk: "2", names: %{a: "aye"}, permissions: %{}, email: "3", presentation: %{b: "bee"}}
      changes = %{names: %{c: "sea"}, email: "4"}
      cs = Changeset.cast(test_user, changes, [:pk, :sk, :names, :permissions, :email, :presentation])
      assert Enum.sort([:pk, :sk, :permissions, :presentation]) == Enum.sort(Transform.find_constraints(cs))
    end

    test "can build condition set from constraints" do
      test_user = %User{pk: "1", sk: "2", names: %{a: "aye"}, permissions: %{}, email: "3", presentation: %{b: "bee"}}
      changes = %{names: %{c: "sea"}, email: "4"}
      cs = Changeset.cast(test_user, changes, [:pk, :sk, :names, :permissions, :email, :presentation])
      actual = Transform.build_conditions_from_constraints(Transform.find_constraints(cs))
      expected = ["attribute_exists(sk)", "attribute_exists(presentation)",
        "attribute_exists(pk)", "attribute_exists(permissions)"]
      assert actual == expected
    end

    test "can build a record from the changeset" do
      test_user = %User{pk: "1", sk: "2", names: %{a: "aye"}, permissions: %{}, email: "3", presentation: %{b: "bee"}}
      changes = %{names: %{c: "sea"}, email: "4"}
      cs = Changeset.cast(test_user, changes, [:pk, :sk, :names, :permissions, :email, :presentation])
      actual = Transform.to_record(cs)
      assert %Record{} = actual
      %Record{data: data, constraints: _} = actual
      assert data == Map.from_struct(test_user) |> Map.merge(changes)
    end
  end
end