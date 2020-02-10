defmodule Tradewinds.Accounts.User do
  @moduledoc """
  Accounts - User model
"""

  alias Tradewinds.Crypto.KennelId

  #  Example struct
  #  %User{
  #    id: "aaaabbbbccccdddd",
  #    name: %{hash: "Kunt-Fu Weasel", first: "First", last: "Last"}
  #    permissions: %{trails: [:read], events: [:write]},
  #    avatar_link: "https://somewhere.com/image.png",
  #    email: "test1@test.ord",
  #    creator: "auth0",
  #    kennel: %{name: "Pittsburgh Prolific Procreators Hash House Harriers",
  #              acronym: "P3H3",
  #              geostring: "north_america##united_states#pennsylvania##pittsburgh",
  #              id: "2345"}
  #  }

  defstruct [:id, :name, :permissions, :avatar_link, :email, :kennel, :creator]

  @kennel_keys [:name, :acronym, :geostring]
  @name_keys [:hash, :first, :last]
  @generic_map %{name: :m1, m1: :name, permissions: :m2, m2: :permissions, s1: :email, email: :s1, kennel: :m3,
                 m3: :kennel, creator: :s2, s2: :creator, id: :s3, s3: :id, avatar_link: :s4, s4: :avatar_link,
                 partition_key: :pk_gs1sk_gs2sk, pk_gs1sk_gs2sk: :partition_key, sort_key: :sk_gs1pk,
                 sk_gs1pk: :sort_key, index_key: :gs2_pk, gs2_pk: :index_key}

  @type changeset :: %{errors: list(), data: map()}

  @doc """
  The changeset/2 function is used to build a changeset for a write operation to the datastore
"""
  @spec changeset(struct(), list()) :: changeset
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :permissions, :id, :avatar_link, :email, :kennel, :creator])
    |> validate_required([:name, :permissions, :id, :avatar_link, :email, :kennel, :creator])
    |> validate_not_nil([:name, :permissions, :id, :avatar_link, :email, :kennel, :creator])
    |> validate_kennel()
    |> validate_name()
  end

  @doc """
  This function is used to take an ecto struct and change all the string keys to atoms.

  ## Examples:
    iex> Tradewinds.Accounts.User.atomize_permissions(%User{permissions: %{"users" => [":read", ":write"]}})
    %User{permissions: %{users: [:read, :write]}}
"""
  @doc since: "0.1.0"
  def atomize_permissions(user) do
    user.permissions
    |> Map.new(fn {k, v} -> {String.to_atom(k), Enum.map(v,
                 fn perm ->
                   perm
                   |> String.replace_prefix(":", "")
                   |> String.to_atom
                 end)}
               end)
    |> (fn (permissions, user) -> Map.put(user, :permissions, permissions) end).(user)
  end

  @doc """
    The cast/3 function takes a map, and a list of keys and applies them to a provided struct
  """
  @spec cast(struct(), map(), list()) :: changeset
  def cast(struct, map, keys) do
    Enum.reduce(keys, %{errors: [], data: %{}}, fn key, acc ->
                             cond do
                               Map.has_key?(map, key) ->
                                 acc[:data]
                                 |> Map.put(key, Map.get(map, key))
                                 |> (fn data -> Map.put(acc, :data, data) end).()
                               Map.has_key?(struct, key) ->
                                 acc[:data]
                                 |> Map.put(key, Map.get(struct, key))
                                 |> (fn data -> Map.put(acc, :data, data) end).()
                               true ->
                                 acc[:errors]
                                 |> (fn error_list -> ["Key #{key} not found." | error_list] end).()
                                 |> (fn errors -> Map.put(acc, :errors, errors) end).()
                             end
                           end)
  end

  def to_generic(%{data: data} = changeset) do
    data
    |> add_keys
    |> Enum.reduce(%{}, fn {k, v}, acc -> Map.put(acc, Map.get(@generic_map, k), v) end)
    |> (fn (generics, collection) -> Map.put(collection, :generic, generics) end).(changeset)
  end

  @doc """
    The validate_not_nil/2 function verifies that all keys in a given list are non-nil
"""
  @spec validate_not_nil(changeset, list()) :: changeset
  def validate_not_nil(%{data: data, errors: errors} = changeset, keys) do
    keys
    |> Enum.filter(fn key -> Map.get(data, key, nil) == nil end)
    |> Enum.map(fn key -> "Key #{key} cannot be nil" end)
    |> join_errors(errors)
    |> (fn errors -> Map.put(changeset, :errors, errors) end).()
  end

  @doc """
    The validate_mother/1 function verifies the proper format of the mother_kennel map
  """
  @spec validate_kennel(changeset) :: changeset
  def validate_kennel(%{data: %{kennel: kennel}, errors: errors} = changeset) do
    @kennel_keys
    |> Enum.filter(fn key -> Map.get(kennel, key, nil) == nil end)
    |> Enum.map(fn key -> "Kennel map requires key [:kennel][#{key}] to exist and be non-nil" end)
    |> join_errors(errors)
    |> (fn errors -> Map.put(changeset, :errors, errors) end).()
  end

  def validate_kennel(%{data: %{}, errors: errors} = changeset) do
    ["Key kennel is required to exist and be non-nil"]
    |> join_errors(errors)
    |> (fn errors -> Map.put(changeset, :errors, errors) end).()
  end

  @doc """
    The validate_name/1 function verfies the User name is as expected
  """
  @spec validate_name(changeset) :: changeset
  def validate_name(%{data: %{name: name}, errors: errors} = changeset) do
    @name_keys
    |> Enum.filter(fn key -> Map.get(name, key, nil) == nil end)
    |> Enum.map(fn key -> "Name map requires key [name][#{key}] to exist and be non-nil" end)
    |> join_errors(errors)
    |> (fn errors -> Map.put(changeset, :errors, errors) end).()
  end

  def validate_name(%{data: %{}, errors: errors} = changeset) do
    ["Key name is required to exist and be non-nil"]
    |> join_errors(errors)
    |> (fn errors -> Map.put(changeset, :errors, errors) end).()
  end

  @doc """
  The validate_required/2 function verifies a list of keys are present in the data map
"""
  @spec validate_required(changeset, list()) :: changeset
  def validate_required(%{data: data, errors: errors} = changeset, keys) do
    keys
    |> Enum.filter(fn key -> !Map.has_key?(data, key) end)
    |> Enum.map(fn key -> "Key #{key} is required" end)
    |> join_errors(errors)
    |> (fn errors -> Map.put(changeset, :errors, errors) end).()
  end

  @doc """
  The join_errors function is a mechanism for fast joining of errors to the existing array
"""
  @spec join_errors(list(), list()) :: list()
  def join_errors([], old_errors), do: old_errors
  def join_errors(new_errors, []), do: new_errors
  def join_errors(new_errors, old_errors), do: [new_errors | old_errors]

  @doc """
  This function is used to add keys to the generic data map.  It should be noted that the atom for the keys is
hard-coded here.  Until a mechanism is developed for extracting the proper identifying from some sort of generic schema
map
"""
  defp add_keys(%{id: id, kennel: kennel} = data) do
    data
    |> Map.put(:index_key, "user##{id}")
    |> Map.put(:sort_key, build_sk(kennel))
    |> (fn collection ->
          Map.put(collection, :partition_key, build_pk(id, Map.get(collection, :sort_key)))
        end).()
  end

  defp build_pk(id, kennel_string) do
    "user##{id}@#{kennel_string}"
  end

  defp build_sk(kennel), do: build_kennel(kennel)

  # This stuff probably gets moved to the Kennel module when I get to refactoring that
  defp build_kennel(%{geostring: geo, id: id} = kennel_map) do
    "kennel##{geo}##{id}}"
  end

  defp build_kennel(%{geostring: geo} = kennel_map) do
    "kennel##{geo}##{KennelId.generate()}"
  end
end
