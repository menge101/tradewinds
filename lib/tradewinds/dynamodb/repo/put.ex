defmodule Tradewinds.Dynamo.Repo.Put do
  alias ExAws.Dynamo
  alias Tradewinds.Dynamo.Config
  alias Tradewinds.Dynamo.Changeset
  alias Tradewinds.Dynamo.Changeset.Transform
  alias Tradewinds.Dynamo.OptionBuilder
  alias Tradewinds.Dynamo.OptionBuilder.ConditionExpression
  alias Tradewinds.Dynamo.Record
  alias Tradewinds.Dynamo.Repo
  alias Tradewinds.Helpers.Maps


  @type return_item_collection_metrics_vals() :: :size | :none
  @type put_item_opts :: [
                           condition_expression: binary(),
                           expression_attribute_names: Repo.expression_attribute_names_vals(),
                           expression_attribute_values: Repo.expression_attribute_values_vals(),
                           return_consumed_capacity: Repo.return_consumed_capacity_vals(),
                           return_item_collection_metrics: return_item_collection_metrics_vals(),
                           return_values: Repo.return_values_vals()
                         ]

  @doc """
    The create/1 function is a special case of the put function where it is hard coded to fail if a record with the given
    primary key already exists
  """
  @spec create(map() | %Changeset{} | %Record{}, put_item_opts) :: map()
  def create(record, opts \\ [])
  def create(%Changeset{} = record, opts) do
    create(Transform.to_record(record), opts)
  end

  def create(%Record{} = record, opts) do
    Config.keys()
    |> Enum.reduce(record.constraints, fn key, acc ->
      ConditionExpression.add_non_existence_condition(acc, key)
    end)
    |> (fn conditions -> Map.put(record, :constraints, conditions) end).()
    |> put(opts)
  end

  def create(%{} = record, opts) do
    create(%Record{data: record}, opts)
  end

  @doc """
    The put/2 function exists to facilitate putting a record to the DynamoDB table with additional metadata
  """
  @spec put(map() | %Record{}, put_item_opts) :: map()
  def put(record, opts \\ [])
  def put(%Record{} = record, opts) do
    {conditions, aliases} = record.constraints
                            |> ConditionExpression.compile()
    built_opts = opts
                 |> OptionBuilder.add_put_option(:condition_expression, conditions)
                 |> OptionBuilder.add_put_option(:expression_attribute_names, Maps.invert_map(aliases))
    put(record.data, built_opts)
  end

  def put(record, opts) do
    Config.table_name()
    |> Dynamo.put_item(add_timestamp(record), opts)
    |> ExAws.request
    |> case do
         {:error, message} -> Repo.infer_and_raise_exception(message)
         {:ok, %{}} -> record
       end
  end

  @spec update(map(), put_item_opts) :: map()
  def update(record, opts \\ []) do
    Config.keys()
    |> Enum.reduce(ConditionExpression.init(), fn key, acc ->
      ConditionExpression.add_existence_condition(acc, key)
    end)
    |> ConditionExpression.compile()
    |> (fn conditions -> OptionBuilder.add_put_option(opts, :condition_expression, conditions) end).()
    |> (fn opts -> put(record, opts) end).()
  end

  @spec add_timestamp(map()) :: map()
  defp add_timestamp(record) do
    record
    |> Map.put(:updated_at, DateTime.now!("Etc/UTC") |> DateTime.to_iso8601())
  end
end