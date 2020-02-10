defmodule Tradewinds.Dynamo.Repo.Bulk do
  alias ExAws.Dynamo
  alias Tradewinds.Dynamo.Config

  @type coerced_collection :: list([put_request: [item: map()]] | [delete_request: [item: map()]])
  @type return_consumed_capacity_vals() :: :none | :total | :indexes
  @type return_item_collection_metrics_vals() :: :size | :none
  @type write_collection :: %{optional(:put) => list(map()), optional(:delete) => list(map())}
  @type write_collection_opts() :: [
                                     return_consumed_capacity: return_consumed_capacity_vals(),
                                     return_item_collection_metrics: return_item_collection_metrics_vals()
                                   ]

  @doc """
    The write_collection function exists to perform a single operation, multi-item write.  It also supports deletes.
  """
  @spec write_collection(write_collection, write_collection_opts) :: bool
  def write_collection(collection, opts \\ []) do
    coerce_bulk_collection(collection)
    |> write_coerced_collection(opts)
    |> Tuple.append(0)
    |> handle_results(opts)
  end

  defp handle_results({:ok, %{"UnprocessedItems" => %{}}, _}, _), do: {:ok, :success}
  defp handle_results({:ok, %{"UnprocessedItems" => items}, tries}, opts) do
    Process.sleep(Math.pow(2, tries) * 1000)
    items
    |> write_coerced_collection(opts)
    |> Tuple.append(tries + 1)
    |> handle_results(opts)
  end

  defp handle_results({:error, {exception_type, message}, _}, _) do
    raise("#{exception_type} - #{message}")
  end

  defp write_coerced_collection(coerced_collection, opts) do
    coerced_collection
    |> (fn records, table -> Map.put_new(%{}, table, records) end).(Config.table_name())
    |> Dynamo.batch_write_item(opts)
    |> ExAws.request()
  end

  @spec coerce_bulk_collection(write_collection) :: coerced_collection
  defp coerce_bulk_collection(collection) do
    Enum.reduce(collection, [],
      fn({operation, records}, acc) ->
        case operation do
          :put -> Enum.map(records, fn record -> [put_request: [item: record]] end)
          :delete -> Enum.map(records, fn record -> [delete_request: [key: record]] end)
          other -> raise(ArgumentError, message: "Operation must be either :put or :delete, not #{other}")
        end
        |> Kernel.++(acc)
      end)
  end
end
