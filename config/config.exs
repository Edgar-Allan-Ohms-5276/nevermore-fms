# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :nevermore,
  ecto_repos: [Nevermore.Repo]

# Configures the endpoint
config :nevermore, NevermoreWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "94ffmHeQc96vUTwdMS2QcfOWsD8s7m6MmHbcu+w02RbrpbsAKkKdYZcs9FCenU+I",
  render_errors: [view: NevermoreWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Nevermore.PubSub,
  live_view: [signing_salt: "6S7kRuiJ"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
