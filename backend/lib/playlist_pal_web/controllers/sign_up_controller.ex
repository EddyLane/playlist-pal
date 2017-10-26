defmodule PlaylistPalWeb.SignUpController do

  #@spotify Application.get_env(:playlist_pal, :spotify_api)

  use PlaylistPalWeb, :controller

  action_fallback PlaylistPalWeb.FallbackController

#  alias Spotify.Authentication
  alias Spotify.Authorization
#  alias Spotify.Credentials
#  alias Spotify.Profile
#
#  alias PlaylistPal.Accounts
#  alias PlaylistPalWeb.Guardian
#
  def sign_up(conn, _) do
    redirect conn, external: Authorization.url
  end

  def authenticate(conn, %{"code" => spotify_auth_code}) do
    render(conn, PlaylistPalWeb.ErrorView.render("404.json", %{}))
  end

  def authenticate(conn, _) do
    render(conn, PlaylistPalWeb.ErrorView.render("404.json", %{}))
  end

#  def authenticate(conn, params), do: render(conn, PlaylistPalWeb.ErrorView.render("404.json", params))

#  def dumb_auth(conn, %{"code" => spotify_auth_code}) do
#
#    @spotify.authenticate(spotify_auth_code)
#
#  end
#
#  def authenticate(conn, %{"code" => spotify_auth_code}) do
#    with {:ok, auth} = @spotify.authenticate(spotify_auth_code),
#         {:ok, profile} <- Profile.me(auth),
#         {:ok, user} <- Accounts.get_or_create_user(profile, auth),
#         {:ok, login_token, _} <- Guardian.encode_and_sign(user, %{}, token_ttl: {1, :minute}, token_type: "login")
#      do
#        redirect conn, external: "http://localhost/authenticate?token=#{login_token}"
#    end
#  end
#
#  def login_token(conn, %{"login_token" => login_token}) do
#    with {:ok, claims} <- Guardian.decode_and_verify(login_token),
#         {:ok, user} = Guardian.resource_from_claims(claims),
#         {:ok, _} = Guardian.revoke(login_token),
#         {:ok, access_token, _} <- Guardian.encode_and_sign(user, %{}, token_ttl: {1, :month}, token_type: "access")
#      do
#        conn
#        |> put_resp_header("authorization", "Bearer " <> access_token)
#        |> put_status(:created)
#        |> render("show.json", user: user)
#     end
#  end

end