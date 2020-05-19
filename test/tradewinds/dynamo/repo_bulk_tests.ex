defmodule Tradewinds.Dynamo.Repo.Bulk.Test do
  @moduledoc """
  This module is home for tests of Tradewinds.Dynamo.Repo.Bulk
"""
  use Tradewinds.DataCase

  alias Faker.String, as: FakeString
  alias Tradewinds.Dynamo.Table
  alias Tradewinds.Dynamo.Repo

  describe "bulk writing minutia tests" do
    setup [:create_table]

    test "writing 25 records" do
      records = %{put: generate_bulk_put_records(25)}
      assert_raise(RuntimeError, fn -> Repo.Bulk.write_collection(records) end)
    end

    test "largest successful upload" do
      records = %{put: generate_large_records(23, 400, 1000)}
      assert Repo.write_collection(records) == {:ok, :success}
    end

    test "raises an Argument error for bulk operations other than :put and :delete" do
      records = %{put: generate_bulk_put_records(3),
        delete: generate_bulk_put_records(3),
        hi: generate_bulk_put_records(3)}
      assert_raise(ArgumentError, fn -> Repo.write_collection(records) end)
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