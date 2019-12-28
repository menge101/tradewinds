defmodule Tradewinds.Abilities.Common do
  @moduledoc """
  This module holds common/helper functionality between ability modules.
"""
  def perm?(permissions, set_atom, perm_atom) do
    case Map.get(permissions, set_atom, nil) do
      nil -> false
      perm_set -> Enum.member?(perm_set, perm_atom)
    end
  end
end
