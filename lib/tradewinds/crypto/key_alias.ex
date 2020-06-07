defmodule Tradewinds.Crypto.KeyAlias do
  @moduledoc """
  This module defines a "Probably Unique Identifier" for use as a key alias within DynamoDB API.

  This is nessacary because DYnamoDB has a LOT of reserved keywords.
  https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/ReservedWords.html

  This ID is only intended to be used for small sets of conditions, < 100.
"""

  use Puid, total: 1_000, risk: 1.0e8, charset: :alphanum
end