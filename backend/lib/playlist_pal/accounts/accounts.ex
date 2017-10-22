defmodule PlaylistPal.Accounts do
  
  @moduledoc """
  The Accounts context.
  """
  import Ecto.Query, warn: false

  alias PlaylistPal.Repo
  alias PlaylistPal.User
  alias PlaylistPal.SpotifyTokens

  alias Spotify.Profile
  alias Spotify.Credentials
  alias Spotify.Authentication

  @doc """
  Creates a new user or returns an existing user if already exists

  ## Examples

      iex> get_or_create_user(spotify_profile, spotify_credentials)
      {:ok, %User{}}

      iex> get_or_create_user(%{field: bad_value}, nil)
      {:error, %Ecto.Changeset{}}

  """
  def get_or_create_user(%Profile{} = profile, %Credentials{} = credentials) do
    case get_user_by_spotify_id(profile.id) do
      nil -> user_params(profile, credentials) |> create_user()
      user -> {:ok, user}
    end
  end

  @doc """
  Gets a single user.

  ## Examples

      iex> get_user_by_spotify_id("edlane")
      %User{}

      iex> get_user_by_spotify_id("12415")
      ** nil

  """
  def get_user_by_spotify_id(spotify_id) do
    user = Repo.one(
      from(
        u in User,
        where: u.spotify_id == ^spotify_id,
        preload: :spotify_tokens
      )
    )

    add_spotify_profile_fields_to_user(user)
  end


  @doc """
  Updates a users access token.

  ## Examples

      iex> update_user_spotify_access_token(user, "new_token")
      {:ok, %User{}}

      iex> update_user_spotify_access_token(user, nil)
      {:error, %Ecto.Changeset{}}

  """
  def update_user_spotify_access_token(%User{} = user, new_access_token) do
    new_tokens =
      user.spotify_tokens
      |> SpotifyTokens.changeset(%{access_token: new_access_token})
      |> Repo.update()

    %{ user | spotify_tokens: new_tokens }
  end


  @doc """
  Get a spotify profile for a given user. If spotify credentials are expired will attempt to get a new access key

  ## Examples

      iex> get_spotify_profile(user)
      %Profile{}

  """
  def get_spotify_profile(user, attempt \\ 1)

  def get_spotify_profile(%User{} = user, attempt) when attempt <= 2 do

    tokens = user.spotify_tokens
    creds = Credentials.new(tokens.access_token, tokens.refresh_token)
    profile = Profile.me(creds)

    case profile do

      {:ok, %{"error" => %{"status" => 401}}} ->
        with {:ok, new_creds } <- Authentication.refresh(creds) do
          user
          |> update_user_spotify_access_token(new_creds.access_token)
          |> get_spotify_profile(attempt + 1)
        end

      {:ok, profile } ->
        profile

    end
  end

  def get_spotify_profile(_, attempt) when attempt > 2 do
    raise "Failed after second retry attempt"
  end

  #######################
  ## Private functions ##
  #######################

  defp create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
    |> add_spotify_profile_fields_to_user()
  end

  defp user_params(%Profile{} = profile, %Credentials{} = credentials) do
    %{
      spotify_id: profile.id,
      spotify_tokens: %{
        access_token: credentials.access_token,
        refresh_token: credentials.refresh_token
      }
    }
  end


  defp add_spotify_profile_fields_to_user(%User{} = user) do
    %{:images => images} = get_spotify_profile(user)

    user
    |> add_spotify_image_to_user(images)
  end

  defp add_spotify_profile_fields_to_user(nil), do: nil

  defp add_spotify_image_to_user(%User{} = user, [image|_]), do: %{ user | image: image["url"] }
  defp add_spotify_image_to_user(%User{} = user, []), do: user

end
