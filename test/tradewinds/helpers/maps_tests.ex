defmodule Tradewinds.Test.Helpers.Maps do
  @moduledoc """
    This module is home for tests of Tradewinds.Helpers.Maps
  """
  use Tradewinds.DataCase

  alias Tradewinds.Helpers.Maps

  describe "atomize_map_keys" do
    test "it returns a binary when passed a binary" do
      assert Maps.atomize_map_keys("cheese") == "cheese"
    end

    test "returns a list when passed a list" do
      data = ["flops", "doozy", "wooooooh"]
      assert Maps.atomize_map_keys(data) == data
    end

    test "returns a map when passed a map" do
      data = %{a: "aye", b: "bee", c: "sea"}
      assert Maps.atomize_map_keys(data) == data
    end

    test "returns a map with atom keys if passed a map with string keys" do
      assert Maps.atomize_map_keys(%{"a" => "aye", "b" => "bee"}) == %{a: "aye", b: "bee"}
    end

    test "returns a map with atom keys if passed a map with mixed keys" do
      assert Maps.atomize_map_keys(%{"a" => "aye", :b => "bee"}) == %{a: "aye", b: "bee"}
    end

    test "returns a list of maps with atom keys if passed a list of maps that do not exclusivly have atom keys" do
      data = [%{"a" => "aye"}, %{b: "bee"}, %{:c => "sea", "d" => "dee"}]
      assert Maps.atomize_map_keys(data) == [%{a: "aye"}, %{b: "bee"}, %{c: "sea", d: "dee"}]
    end

    test "returns a nested map with atom keys if passed a nested map" do
      input = %{:one => %{:o => "oh", "n" => "en", "e" => "eee"},
               :two => %{"t" => "tea", "w" => "dubbayou", :o => "oh"},
               "three" => %{:t => "tea", :h => "ayche", "r" => "are"}}
      output = %{one: %{o: "oh", n: "en", e: "eee"},
                 two: %{t: "tea", w: "dubbayou", o: "oh"},
                 three: %{t: "tea", h: "ayche", r: "are"}}
      assert Maps.atomize_map_keys(input) == output
    end

    test "atomizes keys of a list of lists of maps" do
      input = [[%{"a" => "aye"}], [%{"b" => "bee", "c" => "sea"}], [%{"d" => "dee"}]]
      expected = [[%{a: "aye"}], [%{b: "bee", c: "sea"}], [%{d: "dee"}]]
      assert Maps.atomize_map_keys(input) == expected
    end
  end

  describe "invert map" do
    test "swaps keys and values in the map" do
      input = %{a: "aye", b: "bee", c: "sea"}
      expected = %{"aye" => :a, "bee" => :b, "sea" => :c}
      assert Maps.invert_map(input) == expected
    end

    test "swaps key and values even when values are complex" do
      input = %{one: %{two: %{three: "three"}}}
      expected = %{%{two: %{three: "three"}} => :one}
      assert Maps.invert_map(input) == expected
    end
  end

  describe "stringify keys" do
    test "returns a map with all keys as strings from a map with atom or mixed keys" do
      data = %{:a => "aye", "b" => "bee", :c => "sea"}
      expected = %{"a" => "aye", "b" => "bee", "c" => "sea"}
      assert Maps.stringify_keys(data) == expected
    end

    test "only operates on atoms" do
      data = %{[:a, :b] => "one", %{a: "aye"} => "aye"}
      assert Maps.stringify_keys(data) == data
    end

    test "does not do nested map keys" do
      data = %{a: %{b: "bee"}}
      expected = %{"a" => %{b: "bee"}}
      assert Maps.stringify_keys(data) == expected
    end
  end
end
