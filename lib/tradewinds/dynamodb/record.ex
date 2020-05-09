defmodule Tradewinds.Dynamo.Record do
  @moduledoc """
  This module is home to the Record struct, which is used as a interface to the Repo.

  The data within the struct is a basic map, keys and values corresponding to attributes and values withing DynamoDB.
  The constraints are the same structure as the Tradewinds.Dynamo.OptionBuilder.ConditionExpression values.
  THe constraints can be directly compiled.
"""

  @type t :: %__MODULE__{
               attr_names: map(),
               attr_values: map(),
               constraints: list(binary()),
               data: map()
             }

  defstruct [attr_names: %{}, attr_values: %{}, constraints: [], data: %{}]
end