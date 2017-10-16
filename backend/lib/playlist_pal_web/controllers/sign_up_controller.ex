defmodule PlaylistPalWeb.SignUpController do

  use PlaylistPalWeb, :controller

  action_fallback MemzWeb.FallbackController

  alias Spotify.Authentication
  alias Spotify.Authorization
  alias Spotify.Credentials
  alias Spotify.Profile

  alias PlaylistPal.Accounts
  alias PlaylistPalWeb.Guardian

  def sign_up(conn, _) do
    redirect conn, external: Authorization.url
  end

  def authenticate(conn, params) do

    with {:ok, auth} = conn |> Credentials.new |> Authentication.authenticate(params),
         {:ok, profile} <- Profile.me(auth),
         {:ok, user} <- get_user(profile),
         {:ok, spotify_token } <- Accounts.create_spotify_tokens(user, auth),
         {:ok, token, _} <- Guardian.encode_and_sign(user, %{}, token_ttl: {1, :minute})
      do

        redirect conn, external: "http://localhost?login_token=#{token}"

    end

  end

  def login_token(conn, %{"login_token" => login_token}) do

    with {:ok, claims} <- Guardian.decode_and_verify(login_token),
         {:ok, user} = Guardian.resource_from_claims(claims),
         {:ok, _} = Guardian.revoke(login_token)
      do

        IO.puts(claims["access_token"])
        IO.puts(claims["sub"])


        text(conn, "ok")

     end

  end

  defp get_user(profile) do
    case Accounts.get_user_by_spotify_id(profile.id) do
      nil -> Accounts.create_user(%{"spotify_id" => profile.id})
      user -> {:ok, user}
    end
  end

end
