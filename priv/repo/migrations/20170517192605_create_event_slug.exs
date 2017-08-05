defmodule PlaylistPal.Repo.Migrations.CreateEventSlug do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :slug, :string
    end
  end
end
