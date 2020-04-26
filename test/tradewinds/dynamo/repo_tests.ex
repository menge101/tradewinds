defmodule Tradewinds.Dynamo.Repo.Test do
  @moduledoc """
  This module is home for tests of Tradewinds.Dynamo.Common
"""
  use Tradewinds.DataCase

  alias Faker.String, as: FakeString
  alias Tradewinds.Dynamo.QueryBuilder
  alias Tradewinds.Dynamo.Repo
  alias Tradewinds.Dynamo.Table

  @create_attrs %{
    pk: "pk1",
    sk: "aaaa",
    a: "aye",
    b: "bee"
  }

  @update_attrs %{a: "why", b: "zee"}

  describe "with an existing DynamoDB table" do
    setup [:create_table]

    test "can put a record" do
      assert @create_attrs == Repo.put(@create_attrs)
    end

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

    test "can create a record" do
      assert @create_attrs == Repo.create(@create_attrs)
    end

    test "cannot update a record that does not exist" do
      assert_raise(ArgumentError, fn -> Repo.update(@update_attrs) end)
    end
  end

  describe "with a record in a DynamoDB table" do
    setup [:create_table, :create_record]

    test "cannot create a record again" do
      assert_raise(ArgumentError, fn -> Repo.create(@create_attrs) end)
    end

    test "can update the record" do
      update_record = Map.merge(@create_attrs, @update_attrs)
      assert update_record == Repo.update(update_record)
    end

    test "can get a record" do
      assert %{"a" => "aye",
               "b" => "bee",
               "pk" => "pk1",
               "sk" => "aaaa",
               "updated_at" => update_time_stamp} = Repo.get(%{pk: "pk1", sk: "aaaa"})
    end

    test "can put an existing record" do
      new_record = @create_attrs
      |> Map.merge(@update_attrs)
      assert new_record = Repo.put(new_record)
      assert %{
               "a" => "why",
               "b" => "zee",
               "pk" => "pk1",
               "sk" => "aaaa",
               "updated_at" => update_time_stamp
             } = Repo.get(%{pk: "pk1", sk: "aaaa"})
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

    test "can write a collection of records" do
      records = %{put: [%{pk: "pk2", sk: "bbbb", c: "sea", d: "dee"},
                        %{pk: "pk3", sk: "cccc", c: "see", d: "di"}],
                  delete: [%{pk: "pk1", sk: "aaaa"}]}
      assert {:ok, :success} = Repo.Bulk.write_collection(records)
      assert %{} == Repo.get(%{pk: "pk1", sk: "aaaa"})
      assert %{"c" => "sea",
               "d" => "dee",
               "pk" => "pk2",
               "sk" => "bbbb"} == Repo.get(%{pk: "pk2", sk: "bbbb"})
      assert %{"c" => "see",
               "d" => "di",
               "pk" => "pk3",
               "sk" => "cccc"} == Repo.get(%{pk: "pk3", sk: "cccc"})
    end
  end

  describe "bulk writing minutia tests" do
    setup [:create_table]

    test "writing 25 records" do
      records = %{put: generate_bulk_put_records(25)}
      assert_raise(RuntimeError, fn -> Repo.Bulk.write_collection(records) end)
    end

    test "largest successful upload" do
      records = %{put: generate_large_records(23, 400, 1000)}
      assert Repo.Bulk.write_collection(records) == {:ok, :success}
    end

    test "raises an Argument error for bulk operations other than :put and :delete" do
      records = %{put: generate_bulk_put_records(3),
                  delete: generate_bulk_put_records(3),
                  hi: generate_bulk_put_records(3)}
      assert_raise(ArgumentError, fn -> Repo.Bulk.write_collection(records) end)
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

  def generate_bulk_put_records(count) do
    Enum.map(0..count, fn pk -> %{pk: pk, sk: "sk", c: "sea"} end)
  end

  @doc """
  This function was written with the goal of generating a 16+ MB bulk write request.
  However it seems trivial to parameterize the function and have a flexible result
"""
  def generate_large_records(record_count, field_count, field_length) do
    Enum.map(0..record_count, fn pk ->
      Enum.reduce(0..field_count, %{pk: "pk#{pk}", sk: "sk"}, fn count, acc ->
        Map.put_new(acc, "field#{count}", FakeString.base64(field_length) )
      end)
    end)
  end
end
