defmodule PlaylistPal.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do

    create table(:users) do
      add :spotify_id, :string

      timestamps()
    end

    create unique_index(:users, [:spotify_id])

  end

end
