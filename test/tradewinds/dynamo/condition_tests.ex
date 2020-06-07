defmodule Tradewinds.Dynamo.OptionBuilder.ConditionExpression.Tests do
  use Tradewinds.DataCase

  alias Tradewinds.Dynamo.OptionBuilder.ConditionExpression
  alias Tradewinds.Helpers.Maps

  describe "Condition expression" do
    test "can initialize" do
      assert ConditionExpression.init() == []
    end

    test "can add a condition" do
      assert ConditionExpression.add_condition([:a], :b) == [:b, :a]
    end

    test "can add an add_existence_condition" do
      assert [[:attribute_exists, "cheese"]] == ConditionExpression.init()
                                                |> ConditionExpression.add_existence_condition("cheese")
    end

    test "can add an add_non_existence_condition" do
      assert [[:attribute_not_exists, "cheese"]] == ConditionExpression.init()
                                                |> ConditionExpression.add_non_existence_condition("cheese")
    end

    test "can compile the condition list" do
      {compiled_conditions, aliases} = ConditionExpression.init()
      |> ConditionExpression.add_existence_condition("cheese")
      |> ConditionExpression.add_non_existence_condition("penguins")
      |> ConditionExpression.compile()
      inverted_aliases = Maps.invert_map(aliases)
      expected = "attribute_exists(#{Map.get(aliases, "cheese")}) AND" <>
                 " attribute_not_exists(#{Map.get(aliases, "penguins")})"
      assert compiled_conditions == expected
    end

    test "can alias condition names with a provided map" do
      alias_map = %{"cheese" => "a1", "penguins" => "b2"}
      condition_list = ConditionExpression.init()
                       |> ConditionExpression.add_existence_condition("cheese")
                       |> ConditionExpression.add_non_existence_condition("penguins")
      actual = ConditionExpression.alias_conditions(condition_list, alias_map)
      expected = {[[:attribute_exists, "a1"], [:attribute_not_exists, "b2"]], alias_map}
      assert actual == expected
    end

    test "can alias condition names without a provided map" do
      condition_list = ConditionExpression.init()
                       |> ConditionExpression.add_existence_condition("cheese")
                       |> ConditionExpression.add_non_existence_condition("penguins")
      actual = ConditionExpression.alias_conditions(condition_list)
      {[[:attribute_exists, cheese_alias], [:attribute_not_exists, penguins_alias]], alias_map} = actual
      assert Map.get(alias_map, "cheese") == cheese_alias
      assert Map.get(alias_map, "penguins") == penguins_alias
    end
  end
end