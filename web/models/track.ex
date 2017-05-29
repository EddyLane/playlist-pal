defmodule ElixirElmBootstrap.Track do
  use ElixirElmBootstrap.Web, :model

  schema "tracks" do
    field :spotify_id, :string
    belongs_to :user, ElixirElmBootstrap.User

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
