defmodule Tradewinds.Exceptions.GetTimeError do
  @moduledoc """
  This module is home to the exception to raise when there is an error getting current UTC time.
"""
  defexception message: "An error has occurred when attempting to get UTC time"
end
