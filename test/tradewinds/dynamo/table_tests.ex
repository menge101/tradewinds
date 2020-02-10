defmodule Tradewinds.Dynamo.Table.Test do
  @moduledoc """
  This module is home for tests of Tradewinds.Dynamo.Table
"""
  use Tradewinds.DataCase

  alias Tradewinds.Dynamo.Table

  @key_schema [%{"attribute_name" => "pk", "attribute_type" => "string", "key_type" => "HASH"},
               %{"attribute_name" => "sk", "attribute_type" => "string", "key_type" => "RANGE"}]

  describe "Dynamo Tables" do
    setup do
      on_exit fn ->
        Table.delete("test1")
      end
    end

    test "can be created" do
      result = Table.create("test1", @key_schema, [], [], 1, 1, :pay_per_request)
      assert {:ok, %{"TableDescription" => %{"TableName" => "test1"}}} = result
    end

    test "returns an empty list when listing without tables existing" do
      assert [] == Table.list()
    end

    test "returns success when deleting a table that doesn't exist" do
      error = {:error, {"ResourceNotFoundException", "Cannot do operations on a non-existent table"}}
      assert error == Table.delete("does_not_exist")
    end
  end

  describe "Dynamo with an existing table" do
    setup do
      Table.create("test1", @key_schema, [], [], 1, 1, :pay_per_request)

      on_exit fn ->
        Table.delete("test1")
      end
    end

    test "can list existing tables" do
      assert Enum.member?(Table.list(), "test1")
    end

    test "can delete the table" do
      assert Enum.member?(Table.list(), "test1")
      {:ok, %{"TableDescription" => desc}} = Table.delete("test1")
      assert desc["TableName"] == "test1"
      refute Enum.member?(Table.list(), "test1")
    end
  end
end