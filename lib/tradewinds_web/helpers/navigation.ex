defmodule TradewindsWeb.Helpers.Navigation do
  @moduledoc """
  This module holds helper logic for navigation. duh.
"""
  require Logger
  def redirect_back(conn, opts \\ []) do
    Phoenix.Controller.redirect(conn, to: NavigationHistory.last_path(conn, 1, opts))
  end

  def log_history(conn) do
    Logger.debug("#{inspect NavigationHistory.last_paths(conn)}")
  end
end
