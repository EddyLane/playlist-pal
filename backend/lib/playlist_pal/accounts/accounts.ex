defmodule PlaylistPal.Accounts do
  
  @moduledoc """
  The Accounts context.
  """
  import Ecto.Query, warn: false

  alias PlaylistPal.Repo
  alias PlaylistPal.User
  alias PlaylistPal.SpotifyTokens

  @doc """
  Creates a user.
  ## Examples
      iex> create_user(%{field: value})
      {:ok, %User{}}
      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a spotify token pair.
  ## Examples
      iex> create_spotify_tokens(user, %{field: value})
      {:ok, %SpotifyTokens{}}
      iex> create_spotify_tokens(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def create_spotify_tokens(%User{} = user, %Spotify.Credentials{} = creds) do

    %SpotifyTokens{}
    |> SpotifyTokens.changeset(%{
       :access_token => creds.access_token,
       :refresh_token => creds.refresh_token,
       :user_id => user.id
    })
    |> Repo.insert()

  end

  @doc """
  Gets a single user.
  ## Examples
      iex> get_user_by_spotify_id(1)
      %User{}
      iex> get_user_by_spotify_id(9999)
      ** nil
  """
  def get_user_by_spotify_id(spotify_id) do
    Repo.get_by(User, spotify_id: spotify_id)
  end

  @doc """
  Gets a single user.
  Raises `Ecto.NoResultsError` if the User does not exist.
  ## Examples
      iex> get_user!(1)
      %User{}
      iex> get_user!(9999)
      ** (Ecto.NoResultsError)
  """
  def get_user!(id), do: Repo.get!(User, id)

end
