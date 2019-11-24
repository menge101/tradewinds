# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :tradewinds,
  ecto_repos: [Tradewinds.Repo]

# Configures the endpoint
config :tradewinds, TradewindsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "+Oydl8DWxPntUa2fkoBDkxBgEmoDO+dsmuDWPkHWTXqNx39xtg0FqrRnWsmUJyku",
  render_errors: [view: TradewindsWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Tradewinds.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configures Ueberauth
config :ueberauth, Ueberauth,
  providers: [
    auth0: { Ueberauth.Strategy.Auth0, [] },
  ]

# Configures Ueberauth's Auth0 auth provider
config :ueberauth, Ueberauth.Strategy.Auth0.OAuth,
  domain: System.get_env("AUTH0_DOMAIN"),
  client_id: System.get_env("AUTH0_CLIENT_ID"),
  client_secret: System.get_env("AUTH0_CLIENT_SECRET")

config :auth0_ex,
       domain: System.get_env("AUTH0_DOMAIN"),
       mgmt_token: System.get_env("AUTH0_MGMT_TOKEN"),
       connection: System.get_env("AUTH0_CONN_NAME"),
       provider_version: "v0.2.2",
       http_opts: []

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
