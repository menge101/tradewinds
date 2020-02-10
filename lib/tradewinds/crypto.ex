defmodule Tradewinds.Crypto.KennelId do
  @moduledoc """
  This module defines a "Probably Unique Identifier" for use with kennels.

  This ID is ONLY intended to be used at the tail end of the Kennel geostring,
which itself narrows the range of an ID to a very specific Geographical region.

  There will be issues should there ever be more than a million trails in a single geographic region.
  However, that would require a trail every day for 2739 years to happen.  WHat does the world even look like then?
"""
  use Puid, total: 1000000, risk: 1.0e8, charset: :alphanum
end
