defmodule TradewindsWeb.Router do
  use TradewindsWeb, :router
  require Ueberauth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TradewindsWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/trails", TrailController
    resources "/users", UserController
    get "/logout", AuthController, :logout
  end

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
