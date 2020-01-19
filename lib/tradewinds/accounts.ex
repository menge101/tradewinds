defmodule Tradewinds.Accounts do
  require Logger
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Tradewinds.Repo

  alias Tradewinds.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(%{} = map), do: Repo.get_by!(User, map)
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user.

  ## Examples

      iex> get_user!(123)
      {:ok, %User{}}

      iex> get_user!(456)
      {:error, "blah"}

  """
  def get_user(%{} = map) do
    {:ok, get_user!(map)}
  rescue
    _ -> {:error, "User with #{inspect Map.to_list(map)}  not found"}
  end

  def get_user(id) do
    {:ok, get_user!(id)}
  rescue
    _ -> {:error, "User with ID: #{id} not found"}
  end

  @doc """
  Gets permissions for a single user.

  Creates a new user with an empty permission set if user is not found.

  ## Examples

      iex> get_perms(123)
      []

      iex> get_perms(456)
      []

  """
  def get_perms(%{id: id} = _) do
    case Tradewinds.Accounts.get_user(id) do
      {:ok, user} -> user.permissions
      _ -> []
    end
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  alias Tradewinds.Accounts.Registration

  @doc """
  Returns the list of registrations.

  ## Examples

      iex> list_registrations()
      [%Registration{}, ...]

  """
  def list_registrations do
    Repo.all(Registration)
  end

  @doc """
  Gets a single registration.

  Returns `{:ok, %Registration{}}` or `{:error, "Registration with id <id> not found."}`

  ## Examples:
    iex> get_registration(123)
    %Registration{}
    iex> get_registration(456)
    {:error, "Registration with id 456 not found."}
"""
  @doc since: "0.1.0"
  def get_registration(id, load_associations \\ false)
  def get_registration(id, true) do
    id
    |> get_registration!
    |> Repo.preload([:event, :user])
    |> (fn rego -> {:ok, rego} end).()
  rescue
    _ -> {:error, "Registration with id #{id} not found"}
  end

  def get_registration(id, false) do
    id
    |> get_registration!
    |> (fn rego -> {:ok, rego} end).()
  end

  @doc """
  Gets a single registration.

  Raises `Ecto.NoResultsError` if the Registration does not exist.

  ## Examples

      iex> get_registration!(123)
      %Registration{}

      iex> get_registration!(456)
      ** (Ecto.NoResultsError)

  """
  def get_registration!(id), do: Repo.get!(Registration, id)

  @doc """
  Creates a registration.

  ## Examples

      iex> create_registration(%{field: value})
      {:ok, %Registration{}}

      iex> create_registration(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_registration(attrs \\ %{}) do
    changeset = %Registration{} |> Registration.changeset(attrs)
    try do
      Repo.insert(changeset)
    rescue
      pge in Postgrex.Error ->
        {:error, Ecto.Changeset.add_error(changeset, pge.postgres.column, pge.postgres.message)}
    end
  end

  @doc """
  Updates a registration.

  ## Examples

      iex> update_registration(registration, %{field: new_value})
      {:ok, %Registration{}}

      iex> update_registration(registration, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_registration(%Registration{} = registration, attrs) do
    registration
    |> Registration.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Registration.

  ## Examples

      iex> delete_registration(registration)
      {:ok, %Registration{}}

      iex> delete_registration(registration)
      {:error, %Ecto.Changeset{}}

  """
  def delete_registration(%Registration{} = registration) do
    Repo.delete(registration)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking registration changes.

  ## Examples

      iex> change_registration(registration)
      %Ecto.Changeset{source: %Registration{}}

  """
  def change_registration(%Registration{} = registration) do
    Registration.changeset(registration, %{})
  end
end
