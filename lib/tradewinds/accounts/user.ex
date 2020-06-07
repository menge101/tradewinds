defmodule Tradewinds.Accounts.User do
  @moduledoc """
  Accounts - User model
"""

  alias Tradewinds.Crypto.UserId
  alias Tradewinds.Dynamo.Changeset
  alias Tradewinds.Helpers.Maps

  #  Example struct
  #  %User{
  #    pk: "aaaabbbbccccdddd",
  #    sk: "User Details",
  #    names: %{hash: "Kunt-Fu Weasel", first: "First", last: "Last"}
  #    permissions: %{trails: [:read], events: [:write]},
  #    email: "test1@test.ord",
  #    presentation: %{hash_name: "Kunt-Fu Weasel", avatar: "https://somewhere.com/image.png"}
  #  }

  @struct_attrs [:pk, :sk, :names, :permissions, :email, :presentation]
  @name_keys [:first, :last, :hash]
  defstruct @struct_attrs

  @type changeset :: %{errors: list(), data: map()}

  @doc """
  The changeset/2 function is used to build a changeset for a write operation to the datastore
"""
  @spec changeset(struct(), list()) :: changeset
  def changeset(user, attrs) do
    user
    |> Changeset.cast(attrs, @struct_attrs)
    |> add_pk()
    |> add_sk()
    |> add_record_type("user_details")
    |> validate_required(@struct_attrs)
    |> validate_not_nil(@struct_attrs)
    |> validate_names()
  end

  @doc """
  This function is used to take an ecto struct and change all the string keys to atoms.

  ## Examples:
    iex> Tradewinds.Accounts.User.atomize_permissions(%User{permissions: %{"users" => [":read", ":write"]}})
    %User{permissions: %{users: [:read, :write]}}
"""
  @doc since: "0.1.0"
  def atomize_permissions(user) do
    Maps.atomize_map_keys(user.permissions)
    |> (fn (permissions, user) -> Map.put(user, :permissions, permissions) end).(user)
  end

  @doc """
    The validate_not_nil/2 function verifies that all keys in a given list are non-nil
"""
  @spec validate_not_nil(changeset, list()) :: changeset
  def validate_not_nil(%{changes: changes, errors: errors} = changeset, keys) do
    keys
    |> Enum.filter(fn key -> Map.get(changes, key, nil) == nil end)
    |> Enum.map(fn key -> "Key #{key} cannot be nil" end)
    |> Changeset.join_errors(errors)
    |> (fn errors -> Map.put(changeset, :errors, errors) end).()
  end

  @doc """
    The validate_name/1 function verfies the User name is as expected
  """
  @spec validate_names(changeset) :: changeset
  def validate_names(%{changes: %{names: nil}, errors: errors} = changeset) do
    ["Key 'names' is required to exist and be non-nil"]
    |> Changeset.join_errors(errors)
    |> (fn errors -> Map.put(changeset, :errors, errors) end).()
  end

  def validate_names(%{changes: %{names: names}, errors: errors} = changeset) do
    @name_keys
    |> Enum.filter(fn key -> Map.get(names, key, nil) == nil end)
    |> Enum.map(fn key -> "Name map requires key [name][#{key}] to exist and be non-nil" end)
    |> Changeset.join_errors(errors)
    |> (fn errors -> Map.put(changeset, :errors, errors) end).()
  end

  def validate_names(%{changes: %{}, errors: errors} = changeset) do
    ["Key 'names' is required to exist and be non-nil"]
    |> Changeset.join_errors(errors)
    |> (fn errors -> Map.put(changeset, :errors, errors) end).()
  end

  @doc """
  The validate_required/2 function verifies a list of keys are present in the data map
"""
  @spec validate_required(changeset, list()) :: changeset
  def validate_required(%{changes: changes, errors: errors} = changeset, keys) do
    keys
    |> Enum.filter(fn key -> Map.has_key?(changes, key) end)
    |> Enum.map(fn key -> "Key #{key} is required" end)
    |> Changeset.join_errors(errors)
    |> (fn errors -> Map.put(changeset, :errors, errors) end).()
  end

  @doc """
  This function is used to add keys to changeset if they do not exist.
map
"""
  defp add_pk(changeset)
  defp add_pk(%{changes: %{pk: nil, names: %{first: first, last: last}} = changes} = changeset) do
    changes
    |> Map.put(:pk, build_pk(last, first))
    |> (fn collection -> Map.put(changeset, :changes, collection) end).()
  end
  # Do nothing if :pk exists, or if names aren't present.
  defp add_pk(changeset), do: changeset

  defp add_record_type(changeset, record_type)
  defp add_record_type(%{changes: %{record_type: _}} = changeset, _), do: changeset
  defp add_record_type(%{changes: %{} = changes} = changeset, record_type) do
    changes
    |> Map.put(:record_type, record_type)
    |> (fn collection -> Map.put(changeset, :changes, collection) end).()
  end

  defp add_sk(changeset)
  defp add_sk(%{changes: %{sk: nil} = changes} = changeset) do
    changes
    |> Map.put(:sk, "user_details")
    |> (fn collection -> Map.put(changeset, :changes, collection) end).()
  end
  # Do nothing if :sk exists
  defp add_sk(changeset), do: changeset

  defp build_pk(last, first) do
    "user##{last}##{first}##{UserId.generate()}"
  end
end
