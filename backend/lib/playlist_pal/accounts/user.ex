defmodule PlaylistPal.Accounts.User do

  use Ecto.Schema
  import Ecto.Changeset
  alias PlaylistPal.Accounts.User

  schema "users" do
    field :name, :string
    field :username, :string
    field :password, :string, virtual: true
    field :token, :string, virtual: true
    field :password_hash, :string

    has_many :playlists, PlaylistPal.Playlists.Playlist

    timestamps()
  end

  @doc false
  def changeset(%User{} = user_new, attrs) do
    user_new
    |> cast(attrs, [:name, :username])
    |> validate_required([:name, :username])
    |> validate_length(:username, min: 1, max: 20)
    |> unique_constraint(:username)
  end


  def registration_changeset(model, params) do
    model
    |> changeset(params)
    |> cast(params, ~w(password))
    |> validate_required([:password])
    |> validate_length(:password, min: 6, max: 100)
    |> put_pass_hash()
  end

  def login_changeset(model) do
    model
    |> cast(%{}, ~w())
  end

  def login_changeset(model, params) do
    model
    |> cast(params, ~w(username password), ~w())
    |> validate_password
  end

  def valid_password?(nil, _), do: false
  def valid_password?(_, nil), do: false
  def valid_password?(password, crypted), do: Comeonin.Bcrypt.checkpw(password, crypted)

  defp validate_password(changeset) do
    case Ecto.Changeset.get_field(changeset, :password_hash) do
      nil -> password_incorrect_error(changeset)
      crypted -> validate_password(changeset, crypted)
    end
  end

  defp validate_password(changeset, crypted) do
    password = Ecto.Changeset.get_change(changeset, :password)
    if valid_password?(password, crypted), do: changeset, else: password_incorrect_error(changeset)
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end

  defp password_incorrect_error(changeset), do: Ecto.Changeset.add_error(changeset, :password, "is incorrect")

end
