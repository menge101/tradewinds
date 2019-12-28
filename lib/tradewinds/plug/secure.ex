defmodule Tradewinds.Plug.Secure do
  @moduledoc """
  This module is home to the Auth0 authentication plug.
"""

  require Logger
  import Plug.Conn

  def init(options), do: options

  def call(conn, _opts) do
    case get_session(%{request_path: path} = conn, :current_user) do
      nil ->
        conn
        |> put_session(:navigation_path, path)
        |> Phoenix.Controller.redirect(to: "/auth/auth0")
        |> halt
      user ->
        conn
        |> assign(:current_user, user)
    end
  end
end
