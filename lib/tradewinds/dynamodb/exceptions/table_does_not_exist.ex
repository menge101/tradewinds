defmodule Tradewinds.Dynamo.Exceptions.TableDoesNotExist do
  @moduledoc """
  This module is home to the exception to raise when the table being called does not exist
"""
  defexception message: "Table does not exist"
end