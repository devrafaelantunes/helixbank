# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :helixbank,
  ecto_repos: [Helixbank.Repo]

# Configures the endpoint
config :helixbank, HelixbankWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "PLDl3TZxPqU1cc69PUzml9NQggw732j+iCX7Xz5giQ29XIr/LR73Z5Q5d/mqpgDO",
  render_errors: [view: HelixbankWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Helixbank.PubSub,
  live_view: [signing_salt: "kgN4y5sy"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
