defmodule UserFromAuth do
  @moduledoc """
  Retrieve the user information from an auth request
  """
  require Logger
  require Poison

  alias Ueberauth.Auth
  alias Tradewinds.Accounts
  alias Tradewinds.Accounts.User

  def find_or_create(%Auth{provider: :identity} = auth) do
    case validate_pass(auth.credentials) do
      :ok -> find_or_create_guts(auth)
      {:error, reason} -> {:error, reason}
    end
  end

  def find_or_create(%Auth{} = auth) do
    find_or_create_guts(auth)
  end

  def find_or_create(%Tradewinds.Accounts.User{id: id}), do: Accounts.get_user(id)

  defp find_or_create_guts(auth) do
    case Accounts.get_user(%{auth0_id: auth.uid}) do
      {:ok, user} ->
        User.atomize_permissions(user)
        |> (fn user -> {:ok, user} end).()
      {:error, _} -> extract_useful_stuff(auth) |> Accounts.create_user
    end
  end

  defp extract_useful_stuff(auth_blob) do
    %{uid: auth0_id, info: %{email: email} } = auth_blob
    %{auth0_id: auth0_id, email: email, name: name_from_auth(auth_blob), avatar_url: avatar_from_auth(auth_blob), \
      permissions: %{}}
  end

  # github does it this way
  defp avatar_from_auth( %{info: %{urls: %{avatar_url: image}} }), do: image

  # facebook does it this way
  defp avatar_from_auth( %{info: %{image: image} }), do: image

  # default case if nothing matches
  defp avatar_from_auth( auth ) do
    Logger.warn auth.provider <> " needs to find an avatar URL!"
    Logger.debug(Poison.encode!(auth))
    nil
  end

  defp basic_info(auth) do
    %{id: auth.uid, name: name_from_auth(auth), avatar: avatar_from_auth(auth)}
  end

  defp name_from_auth(auth) do
    if auth.info.name do
      auth.info.name
    else
      name = [auth.info.first_name, auth.info.last_name]
             |> Enum.filter(&(&1 != nil and &1 != ""))

      cond do
        length(name) == 0 -> auth.info.nickname
        true -> Enum.join(name, " ")
      end
    end
  end

  defp validate_pass(%{other: %{password: ""}}), do: {:error, "Password required"}
  defp validate_pass(%{other: %{password: pw, password_confirmation: pw}}), do: :ok
  defp validate_pass(%{other: %{password: _}}), do: {:error, "Passwords do not match"}
  defp validate_pass(_), do: {:error, "Password Required"}
end
