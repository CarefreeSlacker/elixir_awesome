# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :elixir_awesome,
  ecto_repos: [ElixirAwesome.Repo]

# Configures the endpoint
config :elixir_awesome, ElixirAwesomeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "QGXTqYatqQtqAnuupn+Ywk5aSoVGp+ZSUkuK4Tha7Oj2eZcv1LwwMg2ZRYvjqaPC",
  render_errors: [view: ElixirAwesomeWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ElixirAwesome.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :elixir_awesome, :external,
  readme_file_url: "https://raw.githubusercontent.com/h4cc/awesome-elixir/master/README.md"

config :elixir_awesome, :github_data,
  proxies_list: [
    "zproxy.lum-superproxy.io:22225:lum-customer-hl_96fff6c5-zone-zone_test_fun_box-ip-38.131.159.167:lrzxs947e0j7",
    "zproxy.lum-superproxy.io:22225:lum-customer-hl_96fff6c5-zone-zone_test_fun_box-ip-185.123.242.89:lrzxs947e0j7",
    "zproxy.lum-superproxy.io:22225:lum-customer-hl_96fff6c5-zone-zone_test_fun_box-ip-193.31.74.77:lrzxs947e0j7",
    "zproxy.lum-superproxy.io:22225:lum-customer-hl_96fff6c5-zone-zone_test_fun_box-ip-173.211.111.78:lrzxs947e0j7",
    "zproxy.lum-superproxy.io:22225:lum-customer-hl_96fff6c5-zone-zone_test_fun_box-ip-184.174.58.140:lrzxs947e0j7",
    "zproxy.lum-superproxy.io:22225:lum-customer-hl_96fff6c5-zone-zone_test_fun_box-ip-184.174.62.33:lrzxs947e0j7",
    "zproxy.lum-superproxy.io:22225:lum-customer-hl_96fff6c5-zone-zone_test_fun_box-ip-193.31.74.44:lrzxs947e0j7",
    "zproxy.lum-superproxy.io:22225:lum-customer-hl_96fff6c5-zone-zone_test_fun_box-ip-158.46.158.145:lrzxs947e0j7",
    "zproxy.lum-superproxy.io:22225:lum-customer-hl_96fff6c5-zone-zone_test_fun_box-ip-181.214.181.102:lrzxs947e0j7",
    "zproxy.lum-superproxy.io:22225:lum-customer-hl_96fff6c5-zone-zone_test_fun_box-ip-178.171.113.127:lrzxs947e0j7"
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

if(File.exists?("#{File.cwd!()}/config/secret.exs")) do
  import_config("secret.exs")
end
