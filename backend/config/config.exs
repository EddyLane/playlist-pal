# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :playlist_pal,
  ecto_repos: [PlaylistPal.Repo]

# Configures the endpoint
config :playlist_pal, PlaylistPalWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "9921vusr0V/6gkpa6S3n2q04ApoBby6w6SHvz0aKGEU0/WhuyIMMt5o6M3ejdgo2",
  render_errors: [view: PlaylistPalWeb.ErrorView, accepts: ~w(json), default_format: "json"],
  pubsub: [name: PlaylistPal.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configures Guardian
config :playlist_pal, PlaylistPalWeb.Guardian,
       issuer: "PLAYLIST_PAL",
       secret_key: "CyNQmG/EVQdO2MFxIKYVhjNV1SAZ/3Inn1fn5CnxJL8vmLe/5VyCR0MLunFk5e3R",
       error_handler: PlaylistPalWeb.ErrorHandler

config :guardian_db, GuardianDb,
       repo: PlaylistPal.Repo,
       schema_name: "guardian_tokens", # default
       sweep_interval: 60 # default: 60 minutes

config :cors_plug,
  expose: ['Authorization']

config :spotify_ex,
  client_id: System.get_env("SPOTIFY_CLIENT_ID"),
  secret_key: System.get_env("SPOTIFY_CLIENT_SECRET"),
  scopes: ["user-read-email"],
  callback_url: "http://localhost:4000/v1/authenticate"



# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"