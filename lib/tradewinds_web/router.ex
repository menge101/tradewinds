defmodule TradewindsWeb.Router do
  @moduledoc """
  Defines routing within the Tradewinds application.
"""
  use TradewindsWeb, :router
  require Ueberauth

  @doc """
  The browser pipeline defines a series of operations that every gui-centric request goes through prior to dispatch.
"""
  @doc since: "0.1.0"
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug NavigationHistory.Tracker
  end

  @doc """
  The api pipeline defines operations to perform on requests made of the api.
"""
  @doc since: "0.1.0"
  pipeline :api do
    plug :accepts, ["json"]
  end

  @doc """
  This scope defines the root routes.
"""
  @doc since: "0.1.0"
  scope "/", TradewindsWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/events", EventController
    resources "/trails", TrailController
    resources "/users", UserController
    get "/logout", AuthController, :logout
  end

  @doc """
  The /auth scope is used for all routes related to authentication.
"""
  @doc since: "0.1.0"
  scope "/auth", TradewindsWeb do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
  end

  # Other scopes may use custom stacks.
  # scope "/api", TradewindsWeb do
  #   pipe_through :api
  # end
end
