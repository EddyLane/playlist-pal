ExUnit.start

Ecto.Adapters.SQL.Sandbox.mode(PlaylistPal.Repo, :manual)

Application.ensure_all_started(:mox)

Mox.defmock(PlaylistPal.Spotify.Mock , for: PlaylistPal.Spotify)