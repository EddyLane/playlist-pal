# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :elixir_elm_bootstrap,
  ecto_repos: [ElixirElmBootstrap.Repo]

# Configures the endpoint
config :elixir_elm_bootstrap, ElixirElmBootstrap.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "9921vusr0V/6gkpa6S3n2q04ApoBby6w6SHvz0aKGEU0/WhuyIMMt5o6M3ejdgo2",
  render_errors: [view: ElixirElmBootstrap.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ElixirElmBootstrap.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :guardian, Guardian,
  allowed_algos: ["HS512"], # optional
  verify_module: Guardian.JWT,  # optional
  issuer: "MyApp",
  ttl: { 30, :days },
  allowed_drift: 2000,
  verify_issuer: true, # optional
  secret_key: to_string(Mix.env),
  serializer: ElixirElmBootstrap.GuardianSerializer

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"