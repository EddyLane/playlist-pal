defmodule PlaylistPal.Track do

  use Ecto.Schema
  import Ecto.Changeset
  alias PlaylistPal.Track

  schema "tracks" do
    field :spotify_id, :string
    belongs_to :user, PlaylistPal.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:spotify_id])
    |> validate_required([:spotify_id])
  end
end
