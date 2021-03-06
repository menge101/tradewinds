defmodule Tradewinds.Trails do
  @moduledoc """
  The Trails context.
  """

  import Ecto.Query, warn: false
  alias Tradewinds.Repo

  alias Tradewinds.Trails.Trail

  @doc """
  Returns the list of trails.

  ## Examples

      iex> list_trails()
      [%Trail{}, ...]

  """
  def list_trails do
    Repo.all(Trail)
  end

  @doc """
  Returns all trails in the future.

  ## Examples

    iex> list_future_trails()
    [%Trail{}, ...]

  """
  def list_future_trails do
    query = from t in Tradewinds.Trails.Trail, where: t.start >= ^DateTime.utc_now
    Repo.all(query)
  end

  @doc """
  Gets a single trail.

  Raises `Ecto.NoResultsError` if the Trail does not exist.

  ## Examples

      iex> get_trail!(123)
      {:ok, %Trail{}}

      iex> get_trail!(456)
      {:error, "Trail with ID: 456 not found"}

  """
  def get_trail(id) do
    {:ok, get_trail!(id)}
  rescue
    _ -> {:error, "Trail with ID: #{id} not found"}
  end

  @doc """
  Gets a single trail.

  Raises `Ecto.NoResultsError` if the Trail does not exist.

  ## Examples

      iex> get_trail!(123)
      %Trail{}

      iex> get_trail!(456)
      ** (Ecto.NoResultsError)

  """
  def get_trail!(id), do: Repo.get!(Trail, id)

  @doc """
  Creates a trail.

  ## Examples

      iex> create_trail(%{field: value})
      {:ok, %Trail{}}

      iex> create_trail(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_trail(attrs \\ %{}) do
    %Trail{}
    |> Trail.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a trail.

  ## Examples

      iex> update_trail(trail, %{field: new_value})
      {:ok, %Trail{}}

      iex> update_trail(trail, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_trail(%Trail{} = trail, attrs) do
    trail
    |> Trail.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Trail.

  ## Examples

      iex> delete_trail(trail)
      {:ok, %Trail{}}

      iex> delete_trail(trail)
      {:error, %Ecto.Changeset{}}

  """
  def delete_trail(%Trail{} = trail) do
    Repo.delete(trail)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking trail changes.

  ## Examples

      iex> change_trail(trail)
      %Ecto.Changeset{source: %Trail{}}

  """
  def change_trail(%Trail{} = trail) do
    Trail.changeset(trail, %{})
  end
end
