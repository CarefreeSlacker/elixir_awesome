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
  proxies_list: ["http://google.ru", "http://ya.ru", "http://mail.ru"],
  between_requests_interval: 5000

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
