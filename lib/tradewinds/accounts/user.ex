defmodule Tradewinds.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Canada.Can

  schema "users" do
    field :auth0_id, :string
    field :name, :string
    field :permissions, {:map, {:array, :string}}
    field :avatar_link, :string
    field :email, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :permissions, :auth0_id, :avatar_link, :email])
    |> validate_required([:permissions, :auth0_id, :email])
  end

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