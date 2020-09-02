# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :nevermore, Nevermore.Repo,
  database: "nevermore_repo",
  username: "user",
  password: "pass",
  hostname: "localhost"

config :nevermore, Nevermore.UserManager.Guardian,
       issuer: "nevermore",
       secret_key: "YYJf9ZTzCVv3yC5dvCVDL3ttcSB9pvTO9yuBTj2+Wjpk3QgG28M86C2pFlYUBFcT" # put the result of the mix command above here

config :nevermore,
  ecto_repos: [Nevermore.Repo]


# Configures the endpoint
config :nevermore, NevermoreWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Il+CsSGfAn4vXvHgOMfxizeNSZ8qGkPVYJ7GydB+ABN/a7eN7E23Wm6VTJs4esDd",
  render_errors: [view: NevermoreWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Nevermore.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "R8lX/UzmwdwsWAPEwFrd011NZHSetvj6Bi3zImGSj8Zvw1T/w0OdNRybCQ5K/19q"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
