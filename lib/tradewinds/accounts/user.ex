defmodule Tradewinds.Accounts.User do
  @moduledoc """
  Accounts - User model
"""
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :auth0_id, :string
    field :name, :string
    field :permissions, {:map, {:array, :string}}
    field :avatar_link, :string
    field :email, :string
    field :creator, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :permissions, :auth0_id, :avatar_link, :email])
    |> unique_constraint(:auth0_id)
    |> validate_required([:permissions, :auth0_id, :email])
  end

  @doc """
  This function is used to take an ecto struct and change all the string keys to atoms.

  ## Examples:
    iex> Tradewinds.Accounts.User.atomize_permissions(%User{permissions: %{"users" => [":read", ":write"]}})
    %User{permissions: %{users: [:read, :write]}}
"""
  @doc since: "0.1.0"
  def atomize_permissions(user) do
    user.permissions
    |> Map.new(fn {k, v} -> {String.to_atom(k), Enum.map(v,
                 fn perm ->
                   perm
                   |> String.replace_prefix(":", "")
                   |> String.to_atom
                 end)}
               end)
    |> (fn (permissions, user) -> Map.put(user, :permissions, permissions) end).(user)
  end
end
