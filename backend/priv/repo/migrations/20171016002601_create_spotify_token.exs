defmodule PlaylistPal.Repo.Migrations.CreateSpotifyToken do
  use Ecto.Migration

  def change do

    create table(:spotify_tokens) do
      add :access_token, :string
      add :refresh_token, :string
      add :user_id, references(:users), null: false

      timestamps()
    end

  end
end
