# credo:disable-for-this-file
defmodule Tradewinds.Fixtures.Common do
  @moduledoc false

  def debug_io(entity, message) do
    IO.puts message
    IO.inspect entity
    entity
  end
end
