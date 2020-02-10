defmodule Tradewinds.Fixtures.User do
  @moduledoc false

  alias Tradewinds.Accounts.User

  @valid_kennel %{name: "Test Kennel", acronym: "TKH3", geostring: "europe#balkans#greece#pelopennesia#sparta"}
  @valid_name %{hash: "Something vaguely crass", first: "John", last: "Crass"}
  @invalid_attrs %{auth0_id: nil, email: nil, name: nil, permissions: nil, creator: nil}

  def user_attrs(overloads \\ %{}) do
    Map.merge(
      %{
        id: "an auth0_id",
        name: @valid_name,
        email: "some@email.com",
        permissions: %{},
        creator: "exunit tests",
        avatar_link: "https://someline.com",
        kennel: @valid_kennel
      }, overloads)
  end

  def invalid_attrs(overloads \\ %{}) do
    Map.merge(@invalid_attrs, overloads)
  end

  def create_user(perms, overrides \\ %{}) do
    user_attrs()
    |> Map.merge(overrides)
    |> Map.put(:permissions, perms)
    |> (fn attrs -> fixture(:user, attrs) end).()
    |> (fn user -> {:ok, user: user} end).()
  end

  def current_user(perms) do
    user_attrs()
    |> Map.put(:permissions, perms)
    |> Map.put(:id, 99)
    |> (fn attrs -> fixture(:user, attrs) end).()
    |> (fn user -> {:ok, current_user: user} end).()
  end

  def fixture(:user, attrs) do
    attrs
    |> (fn (precedent_map, other_map) -> Map.merge(other_map, precedent_map) end).(user_attrs())
    |> (fn (attrs, struct) -> struct(struct, attrs) end).(%User{})
  end

  def error_response(message) do
    {:error, message}
  end

  def no_instance_permission do
    error_response("Current user does not have permission to perform this action on this user.")
  end

  def cannot_delete_self do
    error_response("You cannot delete yourself")
  end

  def no_self_permission do
    error_response("User cannot perform this action on themselves")
  end
end
