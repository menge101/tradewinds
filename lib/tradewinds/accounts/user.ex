defmodule Tradewinds.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :auth0_id, :string
    field :name, :string
    field :permissions, {:array, :string}

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :permissions, :auth0_id])
    |> validate_required([:name, :permissions, :auth0_id])
  end
end
