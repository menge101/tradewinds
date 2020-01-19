defmodule Tradewinds.Abilities.Common do

  alias Tradewinds.Exceptions.GetTimeError

  @moduledoc """
  This module holds common/helper functionality between ability modules.
"""
  @doc """
  This function defines the tuple to return when a user is approved to perform an action on an entity

  Returns `{:ok, true}`

  ## Examples:
    iex> Tradewinds.Abilities.Common.approved()
    {:ok, true}
"""
  @doc since: "0.1.0"
  def approved do
    {:ok, true}
  end

  @doc """
  This method is used to determine if a date is in the past.

  Returns `true` or `false`

  ## Examples:
    iex> Tradewinds.Abilities.Common.historical?(~U[1900-04-17 14:00:00Z])
    true
    iex> Tradewinds.Abilities.Common.historical?(~U[9999-04-17 14:00:00Z])
    false
"""
  @doc since: "0.1.0"
  def historical?(start) do
    case DateTime.now("Etc/UTC") do
      {:ok, current} ->
        case DateTime.compare(start, current) do
          :gt -> false
          :eq -> false
          :lt -> true
        end
      _ -> raise GetTimeError
    end
  end

  @doc """
  This function defines the tuple to return when an invalid request has been made of the authorization framework

  Returns `{:error, "A(n) Event instance is not relevant to creating Events"}`

  ## Examples:
    iex> Tradewinds.Abilities.Common.invalid_instance_request("Event", :create)
    {:error, "A(n) Event instance is not relevant to createing Events"}

    iex> Tradewinds.Abilities.Common.invalid_instance_request("Anything", :anything)
    {:error, "A(n) Anything instance is not relevant to anythinging Anythings"}

    iex> Tradewinds.Abilities.Common.invalid_instance_request("Event", "create")
    ** (ArgumentError) argument error
"""
  @doc since: "0.1.0"
  def invalid_instance_request(struct_name, action) do
    {:error, "A(n) #{struct_name} instance is not relevant to #{Atom.to_string(action)}ing #{struct_name}s"}
  end

  @doc """
  This function defines the tuple to return when a user does not have access to a particular type of content.
  This applies, typically, to creation and listing actions.

  ## Examples:
    iex> Tradewinds.Abilities.Common.no_access_permission
    {:error, "Current user does not have permission to access this content"}
"""
  @doc since: "0.1.0"
  def no_access_permission do
    {:error, "Current user does not have permission to access this content"}
  end

  @doc """
  This function defines the response to give when a user does not have permission to act on an instance of an entity.
  This applies typically to :read, :write, and :delete actions.

  ## Examples:
    iex> Tradewinds.Abilities.Common.no_instance_permission("test")
    {:error, "Current user does not have permission to perform this action on this test."}
"""
  @doc since: "0.1.0"
  def no_instance_permission(entity_name) do
    {:error, "Current user does not have permission to perform this action on this #{entity_name}."}
  end

  @doc """
  This function parses the permission set, and looks for a specific atom within a specific permission subset

  Return `true` or `false`

  ##Examples:
    iex> Tradewinds.Abilities.Common.perm?(%{a: [:aye, :eh, :a], b: [:bee, :be, :b], c: [:sea, :see, :c]}, :c, :see)
    true
    iex> Tradewinds.Abilities.Common.perm?(%{a: [:aye, :eh, :a], b: [:bee, :be, :b], c: [:sea, :see, :c]}, :a, :see)
    false
"""
  @doc since: "0.1.0"
  def perm?(permissions, set_atom, perm_atom) do
    case Map.get(permissions, set_atom, nil) do
      nil -> false
      perm_set -> Enum.member?(perm_set, perm_atom)
    end
  end
end
