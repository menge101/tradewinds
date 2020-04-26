defmodule Tradewinds.Dynamo.Config.Test do
  @moduledoc """
  This module is home to tests for Tradewinds.Dynamo.Config
"""
  use Tradewinds.DataCase

  alias Tradewinds.Dynamo.Config

  describe "Config" do
    test "can extract primary keys" do
      assert ["pk", "sk"] == Config.keys()
    end

    test "can extract the hash key" do
      assert "pk" == Config.key("HASH")
    end

    test "can extract the sort key" do
      assert "sk" == Config.key("RANGE")
    end

    test "raises ArgumentError for invalid key_type" do
      assert_raise ArgumentError, fn -> Config.key("blam") end
    end

    test "can extract table name" do
      assert "testwinds" == Config.table_name()
    end
  end
end