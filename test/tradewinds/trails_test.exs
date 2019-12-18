defmodule Tradewinds.TrailsTest do
  use Tradewinds.DataCase

  alias Tradewinds.Trails
  alias Tradewinds.Accounts
  
  @creator_attrs %{auth0_id: "creator auth0_id", name: "some name", email: "creator@email.com", permissions: %{}, creator: "exunit test"}
  @valid_attrs %{description: "some description", name: "some name", start: ~U[2010-04-17 14:00:00Z], creator: 99999}
  @update_attrs %{description: "some updated description", name: "some updated name", start: ~U[2011-05-18 15:01:01Z], creator: 888888}
  @invalid_attrs %{description: nil, name: nil, start: nil, creator: nil}

  def fixture(atom, attrs \\ %{})
  def fixture(:trail, attrs) do
    {:ok, trail} = attrs
      |> (fn (precedent_map, other_map) -> Map.merge(other_map, precedent_map) end).(@valid_attrs)
      |> Trails.create_trail
    trail
  end

  def fixture(:creator, _) do
    case Accounts.get_user(@creator_attrs) do
      {:ok, user} -> user
      {:error, _} ->
        {:ok, user} = Accounts.create_user(@creator_attrs)
        user
    end
  end

  describe "trails" do
    alias Tradewinds.Trails.Trail

    def trail_fixture(attrs \\ %{}) do
      {:ok, trail} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Trails.create_trail()

      trail
    end

    test "list_trails/0 returns all trails" do
      trail = fixture(:trail)
      assert Trails.list_trails() == [trail]
    end

    test "get_trail!/1 returns the trail with given id" do
      trail = fixture(:trail)
      assert Trails.get_trail!(trail.id) == trail
    end

    test "create_trail/1 with valid data creates a trail" do
      assert {:ok, %Trail{} = trail} = Trails.create_trail(@valid_attrs)
      assert trail.description == Map.get(@valid_attrs, :description)
      assert trail.name == Map.get(@valid_attrs, :name)
      assert trail.start == Map.get(@valid_attrs, :start)
    end

    test "create_trail/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Trails.create_trail(@invalid_attrs)
    end

    test "update_trail/2 with valid data updates the trail" do
      trail = fixture(:trail)
      assert {:ok, %Trail{} = trail} = Trails.update_trail(trail, @update_attrs)
      assert trail.description == Map.get(@update_attrs, :description)
      assert trail.name == Map.get(@update_attrs, :name)
      assert trail.start == Map.get(@update_attrs, :start)
    end

    test "update_trail/2 with invalid data returns error changeset" do
      trail = fixture(:trail)
      assert {:error, %Ecto.Changeset{}} = Trails.update_trail(trail, @invalid_attrs)
      assert trail == Trails.get_trail!(trail.id)
    end

    test "delete_trail/1 deletes the trail" do
      trail = fixture(:trail)
      assert {:ok, %Trail{}} = Trails.delete_trail(trail)
      assert_raise Ecto.NoResultsError, fn -> Trails.get_trail!(trail.id) end
    end

    test "change_trail/1 returns a trail changeset" do
      trail = fixture(:trail)
      assert %Ecto.Changeset{} = Trails.change_trail(trail)
    end
  end
end
