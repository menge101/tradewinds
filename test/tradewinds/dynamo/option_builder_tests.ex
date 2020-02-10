defmodule Tradewinds.Dynamo.OptionBuilder.Tests do
  @moduledoc """
  This module is home to tests of the Tradewinds.Dynamo.OptionBuilder
"""
  use Tradewinds.DataCase

  alias Tradewinds.Dynamo.OptionBuilder

  describe "Option builder" do
    test "can initialize" do
      assert OptionBuilder.init() == Keyword.new()
    end

    test "can add a valid put option" do
      actual = OptionBuilder.init()
               |> OptionBuilder.add_put_option(:expression_attribute_names, "test value")
      expected = [{:expression_attribute_names, "test value"}]
      assert actual == expected
    end

    test "cannot add an invalid put option" do
      assert_raise(ArgumentError, fn ->
        OptionBuilder.add_put_option(OptionBuilder.init(), :invalid_put_option, "test value")
      end)
    end
  end
end