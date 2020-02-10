defmodule Tradewinds.Dynamo.QueryBuilder.Test do
  @moduledoc """
  This module is home to the tests for the Tradewinds.Dynamo.QueryBuilder
"""
  use Tradewinds.DataCase

  alias Tradewinds.Dynamo.QueryBuilder

  describe "Query Builder" do
    test "can initialize a query" do
      assert QueryBuilder.init() == Keyword.new()
    end

    test "can add an index" do
      query = QueryBuilder.init() |> QueryBuilder.add_index("test")
      assert [index_name: "test"] = query
    end

    test "can add key expression" do
      query = QueryBuilder.init() |> QueryBuilder.add_key_cond_exp("pk = :pk")
      assert [key_condition_expression: "pk = :pk"] = query
    end

    test "can add filter expression" do
      query = QueryBuilder.init() |> QueryBuilder.add_filter_exp("a = :a")
      assert [filter_expression: "a = :a"] = query
    end

    test "can add projection expression" do
      query = QueryBuilder.init() |> QueryBuilder.add_projection_exp("a, b, c")
      assert [projection_expression: "a, b, c"] = query
    end

    test "can add limit" do
      query = QueryBuilder.init() |> QueryBuilder.add_limit(1)
      assert [limit: 1] = query
    end

    test "can add start key" do
      query = QueryBuilder.init() |> QueryBuilder.add_start_key(1)
      assert [exclusive_start_key: 1] = query
    end

    test "can use consistent reads" do
      query = QueryBuilder.init() |> QueryBuilder.consistent_read(true)
      assert [consistent_read: true] = query
    end

    test "can return consumed capacity" do
      query = QueryBuilder.init() |> QueryBuilder.return_consumed_cap(true)
      assert [return_consumed_capacity: true] = query
    end

    test "can scan the index forward" do
      query = QueryBuilder.init() |> QueryBuilder.scan_idx_forward(true)
      assert [scan_index_forward: true] = query
    end

    test "can add expression attribute names" do
      query = QueryBuilder.init() |> QueryBuilder.add_exp_attr_names([pk: "pk1", sk: "sortysortsort"])
      assert [expression_attribute_names: [pk: "pk1", sk: "sortysortsort"]] = query
    end

    test "can add expression attribute values" do
      query = QueryBuilder.init() |> QueryBuilder.add_exp_attr_vals([pk: "a", sk: "b"])
      assert [expression_attribute_values: [pk: "a", sk: "b"]] = query
    end
  end
end
