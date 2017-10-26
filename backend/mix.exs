defmodule PlaylistPal.Mixfile do
  use Mix.Project

  def project do
    [
      app: :playlist_pal,
      version: "0.0.1",
      elixir: "~> 1.2",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [plt_add_deps: :transitive]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {PlaylistPal.Application, []},
      extra_applications: [:logger, :runtime_tools, :guardian]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:guardian, "~> 1.0-beta"},
      {:guardian_db, github: "ueberauth/guardian_db", branch: "master"},
      {:poison, "~> 3.1"},
      {:ecto_autoslug_field, "~> 0.3"},
      {:cors_plug, "~> 1.2"},
      {:libcluster, "~> 2.1"},
      {:httpotion, "~> 3.0.2"},
      {:spotify_ex, "~> 2.0.5"},
      {:dogma, "~> 0.1", only: [:dev, :test]},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:distillery, "~> 1.4", runtime: false},
      {:fs, "~> 2.12", override: true},
      {:mix_test_watch, "~> 0.3", only: [:dev], runtime: false},
      {:mock, "~> 0.2.0", only: :test},
      {:mox, "~> 0.1.0", only: :test},
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
    ]
  end
end
