defmodule Tradewinds.Dynamo.Repo.Test do
  @moduledoc """
  This module is home for tests of Tradewinds.Dynamo.Common
"""
  use Tradewinds.DataCase

  alias Faker.String, as: FakeString
  alias Tradewinds.Dynamo.Changeset
  alias Tradewinds.Dynamo.QueryBuilder
  alias Tradewinds.Dynamo.Repo
  alias Tradewinds.Dynamo.Table
  alias Tradewinds.Accounts.User
  alias Tradewinds.Helpers.Maps

  @create_attrs %{
    pk: "pk1",
    sk: "aaaa",
    email: "email@email.email",
    permissions: %{}
  }

  @update_attrs %{a: "why", b: "zee"}

  describe "with an existing DynamoDB table" do
    setup [:create_table]

    test "get on a record that does not exist returns an empty map" do
      assert Repo.get(%{pk: "pk1", sk: "aaaa"}) == %{}
    end

    test "query for records that don't exist returns an empty map" do
      response = QueryBuilder.init()
                 |> QueryBuilder.add_key_cond_exp("pk = :pk AND sk = :sk")
                 |> QueryBuilder.add_exp_attr_vals([pk: "pk1", sk: "aaaa"])
                 |> Repo.query()
      assert response == {:ok, %{"Count" => 0, "Items" => [], "ScannedCount" => 0}}
    end

    test "delete a record that doesn't exist does what?" do
      expected = {:ok, %{"ConsumedCapacity" => %{"CapacityUnits" => 1.0, "TableName" => "testwinds"}}}
      assert expected == Repo.delete(%{pk: "pk1", sk: "aaaa"})
    end
  end

  describe "with a record in a DynamoDB table" do
    setup [:create_table, :create_record]

    test "can get a record" do
      assert %{"a" => "aye",
               "b" => "bee",
               "pk" => "pk1",
               "sk" => "aaaa",
               "updated_at" => update_time_stamp} = Repo.get(%{pk: "pk1", sk: "aaaa"})
    end

    test "can query a record" do
      response = QueryBuilder.init()
      |> QueryBuilder.add_key_cond_exp("pk = :pk AND sk = :sk")
      |> QueryBuilder.add_exp_attr_vals([pk: "pk1", sk: "aaaa"])
      |> Repo.query()
      assert {:ok, %{"Count" => 1, "Items" => [%{"a" => %{"S" => "aye"}, "b" => %{"S" => "bee"}}]}} = response
    end

    test "can delete the record" do
      assert {:ok, %{}} == Repo.delete(%{pk: "pk1", sk: "aaaa"})
    end


  end



  describe "to_struct" do
    alias Tradewinds.Accounts.User

    test "it can turn a map with atomic keys into a struct" do
      map = %{pk: "hi", sk: "there", names: %{a: "aye"},
        permissions: %{}, email: "z", presentation: %{}, other: "stuff"}
      struct = Repo.to_struct(map, User)
      %{pk: "hi", sk: "there", names: %{a: "aye"}, permissions: %{}, email: "z",
        presentation: %{}} == struct
      %User{} = struct
    end

    test "it can turn a map with string keys into a struct" do
      map = %{"pk" => "hi", "sk" => "there", "names" => %{a: "aye"},
        "permissions" => %{}, "email" => "z", "presentation" => %{}, "other" => "stuff"}
      struct = Repo.to_struct(map, User)
      %{pk: "hi", sk: "there", names: %{a: "aye"}, permissions: %{}, email: "z",
        presentation: %{}} == struct
      %User{} = struct
    end

    test "it can turn a mixed map into a struct" do
      map = Map.merge(%{pk: "hi"}, %{"sk" => "there", "names" => %{a: "aye"},
        "permissions" => %{}, "email" => "z", "presentation" => %{}, "other" => "stuff"})
      struct = Repo.to_struct(map, User)
      %{pk: "hi", sk: "there", names: %{a: "aye"}, permissions: %{}, email: "z",
        presentation: %{}} == struct
      %User{} = struct
    end
  end

  def create_record(_), do: {:ok, Repo.put(@create_attrs)}

  def create_table(_) do
    table_def = Application.fetch_env!(:tradewinds, :dynamodb)[:table]
    %{name: table_name} = table_def
    Table.create(table_def)

    on_exit fn ->
      Table.delete(table_name)
    end
  end

  @doc """
  This is a convenience function to get the keys form a struct
"""
  def get_keys_from_struct(struct) do
    Map.from_struct(struct)
    |> Map.delete(:__struct__)
    |> Map.keys()
  end
end
