defmodule ElixirElmBootstrap.Event do
  use ElixirElmBootstrap.Web, :model

  schema "events" do
    field :name, :string
    belongs_to :user, ElixirElmBootstrap.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :user_id])
    |> validate_required([:name, :user_id])
  end
end
