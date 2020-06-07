defmodule Tradewinds.Crypto.UserId do
  @moduledoc """
    This module defines a "Probably Unique Identifier" for use with users.

    This ID is ONLY intended to be used at the tail end of the User name string,
    which itself narrows the range of an ID to a very specific set of people.

    The most popular given name in the world is Zhang Wei, of which 290,607 people have.

    This ID allows for 10 million people with the same name.
  """
  use Puid, total: 10_000_000, risk: 1.0e8, charset: :alphanum
end
