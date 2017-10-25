use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application.
config :playlist_pal, PlaylistPalWeb.Endpoint,
  http: [port: System.get_env("PORT")],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  url: [host: "localhost", port: System.get_env("PORT")]

# Watch static and templates for browser reloading.
config :playlist_pal, PlaylistPalWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/playlist_pal_web/views/.*(ex)$},
      ~r{lib/playlist_pal_web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :playlist_pal, PlaylistPal.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("POSTGRES_USER"),
  password: System.get_env("POSTGRES_PASSWORD"),
  hostname: System.get_env("POSTGRES_HOST"),
  database: System.get_env("POSTGRES_DB"),
  pool_size: 10

config :mix_test_watch,
  clear: true

# Configure environment specific things
config :playlist_pal, :spotify_api, PlaylistPal.Spotify.HTTPClient