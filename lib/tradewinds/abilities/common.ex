defmodule Tradewinds.Abilities.Common do
  @moduledoc """
  This module holds common/helper functionality between ability modules.
"""
  def approved do
    {:ok, true}
  end

  def invalid_request(struct_name, action) do
    {:error, "A(n) #{struct_name} instance is not relevant to #{Atom.to_string(action)}ing #{struct_name}s"}
  end

  def no_access_permission do
    {:error, "Current user does not have permission to access this content"}
  end

  def perm?(permissions, set_atom, perm_atom) do
    case Map.get(permissions, set_atom, nil) do
      nil -> false
      perm_set -> Enum.member?(perm_set, perm_atom)
    end
  end
end
