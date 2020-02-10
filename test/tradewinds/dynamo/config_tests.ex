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

    test "can extract table name" do
      assert "testwinds" == Config.table_name()
    end
  end
end