use Mix.Config

# Configure your database
config :tradewinds, Tradewinds.Repo,
  username: "postgres",
  password: "postgres",
  database: "tradewinds_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :tradewinds, TradewindsWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :tradewinds, :dynamodb, tablename: "testwinds"

config :ex_aws,
       debug_requests: false, # set to true to monitor the DDB requests
       access_key_id: "abcd",
       secret_access_key: "1234",
       region: "us-east-1"

config :ex_aws, :dynamodb,
       scheme: "http://",
       host: "localhost",
       port: 8000,
       region: "us-east-1"

config :tradewinds, :dynamodb,
       table: %{ name: "testwinds",
         key_schema: [
           %{
             attribute_name: "pk",
             attribute_type: "string",
             key_type: "HASH"
           },
           %{
             attribute_name: "sk",
             attribute_type: "string",
             key_type: "RANGE"
           }
         ],
         global_indexes: [],
         local_indexes: [],
         rcu: 1,
         wcu: 1,
         billing_type: :pay_per_request
       }
