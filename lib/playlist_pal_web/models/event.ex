defmodule NameSlug do
  use EctoAutoslugField.Slug, from: :name, to: :slug
end

defmodule PlaylistPal.Event do

  use Ecto.Schema
  import Ecto.Changeset
  alias PlaylistPal.User

  @derive {Poison.Encoder, only: [:id, :name, :slug]}

  schema "events" do
    field :name, :string
    field :slug, NameSlug.Type

    belongs_to :user, PlaylistPal.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :user_id])
    |> validate_required([:name, :user_id])
    |> NameSlug.maybe_generate_slug
    |> NameSlug.unique_constraint
  end
end
