defmodule Tradewinds.Dynamo.Repo.Put.Test do
  @moduledoc """
  This module is home for tests of Tradewinds.Dynamo.Repo.Put
"""
  use Tradewinds.DataCase

  alias Tradewinds.Accounts.User
  alias Tradewinds.Dynamo.Changeset
  alias Tradewinds.Dynamo.Record
  alias Tradewinds.Dynamo.Repo
  alias Tradewinds.Dynamo.Table
  alias Tradewinds.Helpers.Maps

  @create_attrs %{
    pk: "pk1",
    sk: "aaaa",
    email: "email@email.email",
    permissions: %{}
  }

  @update_attrs %{email: "why@why.y", permissions: %{wam: [:read]}}

  describe "with an existing DynamoDB table" do
    setup [:create_table]

    test "can put a record" do
      assert @create_attrs == Repo.Put.put(@create_attrs)
    end

    test "can create a record" do
      assert @create_attrs == Repo.create(@create_attrs)
    end

    test "can create a record from a Changeset" do
      cs = Changeset.cast(%User{}, @create_attrs, get_keys_from_struct(%User{}))
      assert Maps.stringify_keys(@create_attrs) == Repo.create(cs)
    end

    test "cannot update via map a record that does not exist" do
      data = Map.merge(@create_attrs, @update_attrs)
      assert_raise(ArgumentError, fn -> Repo.update(data) end)
    end

    test "cannot update via changeset a record that does not exist" do
      user = Repo.to_struct(@create_attrs, User)
      data = Changeset.cast(user, @update_attrs, get_keys_from_struct(user))
      assert_raise(ArgumentError, fn -> Repo.update(data) end)
    end

    test "cannot update via Record a record that does not exist" do
      data = %Record{data: Map.merge(@create_attrs, @update_attrs)}
      assert_raise(ArgumentError, fn -> Repo.update(data) end)
    end
  end

  describe "with a record in a DynamoDB table" do
    setup [:create_table, :create_record]

    test "cannot create a record again" do
      assert_raise(ArgumentError, fn -> Repo.create(@create_attrs) end)
    end

    test "cannot create a record from a changeset again" do
      assert_raise(ArgumentError, fn ->
        Changeset.cast(%User{}, @create_attrs, get_keys_from_struct(%User{}))
        |> Repo.create()
      end)
    end

    test "cannot create a record from a Record if record already exists" do
      assert_raise(ArgumentError, fn ->
        %Record{data: Map.merge(@create_attrs, @update_attrs)}
        |> Repo.create()
      end)
    end

    test "can update the record using a map" do
      update_record = Map.merge(@create_attrs, @update_attrs)
      assert update_record == Repo.update(update_record)
    end

    test "can update the record using a Changeset" do
      user = Repo.to_struct(@create_attrs, User)
      data = Changeset.cast(user, @update_attrs, get_keys_from_struct(user))
      assert Maps.stringify_keys(Map.merge(@create_attrs, @update_attrs)) == Repo.update(data)
    end

    test "can update the record using a Record" do
      data = Map.merge(@create_attrs, @update_attrs)
      record = %Record{data: data}
      assert data == Repo.update(record)
    end

    test "can put an existing record" do
      new_record = @create_attrs
                   |> Map.merge(@update_attrs)
      assert new_record = Repo.Put.put(new_record)
      assert %{
               "pk" => "pk1",
               "sk" => "aaaa",
               "updated_at" => update_time_stamp,
               "email" => "why@why.y",
               "permissions" => %{"wam" => ["read"]}
             } = Repo.get(%{pk: "pk1", sk: "aaaa"})
    end
  end

  def create_record(_), do: {:ok, Repo.Put.put(@create_attrs)}

  def create_table(_) do
    table_def = Application.fetch_env!(:tradewinds, :dynamodb)[:table]
    %{name: table_name} = table_def
    Table.create(table_def)

    on_exit fn ->
      Table.delete(table_name)
    end
  end

  @doc """
    This is a convenience function to get the keys form a struct
  """
  def get_keys_from_struct(struct) do
    Map.from_struct(struct)
    |> Map.delete(:__struct__)
    |> Map.keys()
  end
end
