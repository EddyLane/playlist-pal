defmodule PlaylistPalWeb.SignUpControllerTest do

  use ExUnit.Case, async: false

  use PlaylistPalWeb.ConnCase
  alias Spotify.Authorization
  import Mock
  alias Spotify.{Authentication}
  alias PlaylistPal.Accounts

  @valid_user %{
    name: "Eddy Lane"
  }

  @valid_playlist %{
    name: "My New Playlist"
  }

  @valid_attrs %{
    user: @valid_user,
    playlist: @valid_playlist
  }

  def valid_auth_mocks do
    [post: fn "https://accounts.spotify.com/api/token", _, _ -> { :ok, AuthenticationClientMock.successful_response() } end,
     get: fn "https://api.spotify.com/v1/me", _ -> { :ok, ProfileClientMock.successful_response() } end
    ]
  end


  describe "successful authentication" do

    defp assertions (conn) do
      conn = get conn, "/v1/authenticate", %{"code" => "valid"}
      conn = Plug.Conn.fetch_cookies(conn)
      assert json_response(conn, 201)["data"] == %{"spotify_id" => "wizzler"}
      assert conn.cookies["spotify_access_token"]  == "access_token"
      assert conn.cookies["spotify_refresh_token"] == "refresh_token"

      assert "wizzler" |> Accounts.get_user_by_spotify_id() != nil
    end

    test "a successful attempt with a new user", %{conn: conn} do
      with_mock(HTTPoison, valid_auth_mocks()) do assertions(conn) end
    end

    test "a successful attempt with an existing user", %{conn: conn} do
      Accounts.create_user(%{"spotify_id" => "wizzler"})
      with_mock(HTTPoison, valid_auth_mocks()) do assertions(conn) end
    end

  end

  describe "create account" do
    test "redirects when requesting sign up", %{conn: conn} do
      conn = get conn, "/v1/sign-up"
      assert redirected_to(conn, 302) == Authorization.url
    end
  end

end

defmodule HTTPoison.Response do
  defstruct body: nil, headers: nil, status_code: nil
end

defmodule AuthenticationClientMock do
  def successful_response do
    %HTTPoison.Response{
      body: "{\"access_token\":\"access_token\",\"token_type\":\"Bearer\",\"expires_in\":3600,\"refresh_token\":\"refresh_token\",\"scope\":\"playlist-read-private\"}",
      headers: [{"Server", "nginx"}, {"Date", "Thu, 21 Jul 2016 16:52:38 GMT"},
        {"Content-Type", "application/json"}, {"Content-Length", "397"},
        {"Connection", "keep-alive"}, {"Keep-Alive", "timeout=10"},
        {"Vary", "Accept-Encoding"}, {"Vary", "Accept-Encoding"},
        {"X-UA-Compatible", "IE=edge"}, {"X-Frame-Options", "deny"},
        {"Content-Security-Policy",
          "default-src 'self'; script-src 'self' foo"},
        {"X-Content-Security-Policy",
          "default-src 'self'; script-src 'self' foo"},
        {"Cache-Control", "no-cache, no-store, must-revalidate"},
        {"Pragma", "no-cache"}, {"X-Content-Type-Options", "nosniff"},
        {"Strict-Transport-Security", "max-age=31536000;"}],
      status_code: 200
    }
  end
end

defmodule ProfileClientMock do
  def successful_response do
    %HTTPoison.Response{
      body: """
  {
        "birthdate": "1937-06-01",
        "country": "SE",
        "display_name": "JM Wizzler",
        "email": "email@example.com",
        "external_urls": {
          "spotify": "https://open.spotify.com/user/wizzler"
        },
        "followers" : {
          "href" : null,
          "total" : 3829
        },
        "href": "https://api.spotify.com/v1/users/wizzler",
        "id": "wizzler",
        "images": [
          {
            "height": null,
            "url": "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-frc3/t1.0-1/1970403_10152215092574354_1798272330_n.jpg",
            "width": null
          }
        ],
        "product": "premium",
        "type": "user",
        "uri": "spotify:user:wizzler"
      }
""",
      headers: [{"Server", "nginx"}, {"Date", "Thu, 21 Jul 2016 16:52:38 GMT"},
        {"Content-Type", "application/json"}, {"Content-Length", "397"},
        {"Connection", "keep-alive"}, {"Keep-Alive", "timeout=10"},
        {"Vary", "Accept-Encoding"}, {"Vary", "Accept-Encoding"},
        {"X-UA-Compatible", "IE=edge"}, {"X-Frame-Options", "deny"},
        {"Content-Security-Policy",
          "default-src 'self'; script-src 'self' foo"},
        {"X-Content-Security-Policy",
          "default-src 'self'; script-src 'self' foo"},
        {"Cache-Control", "no-cache, no-store, must-revalidate"},
        {"Pragma", "no-cache"}, {"X-Content-Type-Options", "nosniff"},
        {"Strict-Transport-Security", "max-age=31536000;"}],
      status_code: 200
    }
  end
end