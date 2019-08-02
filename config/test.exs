use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :elixir_awesome, ElixirAwesomeWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :elixir_awesome, ElixirAwesome.Repo,
  username: "postgres",
  password: "postgres",
  database: "elixir_awesome_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :elixir_awesome, :github_credentials,
  username: "Test",
  password: "Password"

config :elixir_awesome, :github_data,
  proxies_list: [
    "zproxy.lum-superproxy.io:22225:lum-customer-hl_96fff6c5-zone-zone_test_fun_box-ip-38.131.159.167:lrzxs947e0j7"
  ]
