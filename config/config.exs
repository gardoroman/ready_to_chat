# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :ready_to_chat,
  ecto_repos: [ReadyToChat.Repo]

# Configures the endpoint
config :ready_to_chat, ReadyToChatWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "wOVrsJd0C+5OrklEEbQpQzOLpgoJ6H7S/hRyKp3j6Rj7QlsBcYmRFqZaiLCs09gJ",
  render_errors: [view: ReadyToChatWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: ReadyToChat.PubSub,
  live_view: [signing_salt: "3M7XtZcE"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
