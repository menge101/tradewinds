defmodule Tradewinds.Dynamo.Repo.Put.Test do
  @moduledoc """
  This module is home for tests of Tradewinds.Dynamo.Repo.Put
"""
  use Tradewinds.DataCase

  alias Tradewinds.Accounts.User
  alias Tradewinds.Dynamo.Changeset
  alias Tradewinds.Dynamo.Repo
  alias Tradewinds.Dynamo.Repo.Put
  alias Tradewinds.Dynamo.Table
  alias Tradewinds.Helpers.Maps

  @create_attrs %{
    pk: "pk1",
    sk: "aaaa",
    email: "email@email.email",
    permissions: %{}
  }

  @update_attrs %{a: "why", b: "zee"}

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

    test "cannot update a record that does not exist" do
      assert_raise(ArgumentError, fn -> Repo.update(@update_attrs) end)
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

    test "can update the record" do
      update_record = Map.merge(@create_attrs, @update_attrs)
      assert update_record == Repo.update(update_record)
    end

    test "can put an existing record" do
      new_record = @create_attrs
                   |> Map.merge(@update_attrs)
      assert new_record = Repo.Put.put(new_record)
      assert %{
               "a" => "why",
               "b" => "zee",
               "pk" => "pk1",
               "sk" => "aaaa",
               "updated_at" => update_time_stamp
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
