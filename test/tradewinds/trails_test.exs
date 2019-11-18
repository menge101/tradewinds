defmodule Tradewinds.TrailsTest do
  use Tradewinds.DataCase

  alias Tradewinds.Trails

  describe "trails" do
    alias Tradewinds.Trails.Trail

    @valid_attrs %{desription: "some desription", name: "some name", start: ~N[2010-04-17 14:00:00]}
    @update_attrs %{desription: "some updated desription", name: "some updated name", start: ~N[2011-05-18 15:01:01]}
    @invalid_attrs %{desription: nil, name: nil, start: nil}

    def trail_fixture(attrs \\ %{}) do
      {:ok, trail} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Trails.create_trail()

      trail
    end

    test "list_trails/0 returns all trails" do
      trail = trail_fixture()
      assert Trails.list_trails() == [trail]
    end

    test "get_trail!/1 returns the trail with given id" do
      trail = trail_fixture()
      assert Trails.get_trail!(trail.id) == trail
    end

    test "create_trail/1 with valid data creates a trail" do
      assert {:ok, %Trail{} = trail} = Trails.create_trail(@valid_attrs)
      assert trail.desription == "some desription"
      assert trail.name == "some name"
      assert trail.start == ~N[2010-04-17 14:00:00]
    end

    test "create_trail/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Trails.create_trail(@invalid_attrs)
    end

    test "update_trail/2 with valid data updates the trail" do
      trail = trail_fixture()
      assert {:ok, %Trail{} = trail} = Trails.update_trail(trail, @update_attrs)
      assert trail.desription == "some updated desription"
      assert trail.name == "some updated name"
      assert trail.start == ~N[2011-05-18 15:01:01]
    end

    test "update_trail/2 with invalid data returns error changeset" do
      trail = trail_fixture()
      assert {:error, %Ecto.Changeset{}} = Trails.update_trail(trail, @invalid_attrs)
      assert trail == Trails.get_trail!(trail.id)
    end

    test "delete_trail/1 deletes the trail" do
      trail = trail_fixture()
      assert {:ok, %Trail{}} = Trails.delete_trail(trail)
      assert_raise Ecto.NoResultsError, fn -> Trails.get_trail!(trail.id) end
    end

    test "change_trail/1 returns a trail changeset" do
      trail = trail_fixture()
      assert %Ecto.Changeset{} = Trails.change_trail(trail)
    end
  end
end
