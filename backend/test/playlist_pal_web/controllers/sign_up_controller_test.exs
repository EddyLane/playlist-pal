defmodule PlaylistPalWeb.SignUpControllerTest do

  use ExUnit.Case, async: true
  use PlaylistPalWeb.ConnCase

  alias Spotify.Authorization
  alias PlaylistPal.Accounts

  import Mox

  # Make sure mocks are verified when the test exits
  setup do: verify!()

  @dummy_access_creds %Spotify.Credentials{access_token: "access_token", refresh_token: "refresh_token"}
  @dummy_profile %Spotify.Profile{
    id: "eddy125431"
  }

  test "action that redirects to spotify oauth", %{conn: conn} do
    conn = get(conn, "/v1/sign-up")
    assert redirected_to(conn, :found) == Authorization.url
  end

  describe "authenticate action" do

    test "will 404 if no code is supplied", %{conn: conn} do
      conn = get(conn, "/v1/authenticate")
      assert json_response(conn, 404) == %{"errors" => %{"message" => "Not Found"}}
    end

    test "will 400 if the authentication process fails", %{conn: conn} do

      PlaylistPal.Spotify.Mock
      |> expect(:authenticate, fn "invalid" -> {:error, "Failure reason"} end)

      conn = get(conn, "/v1/authenticate", %{"code" => "invalid"})
      assert json_response(conn, 400) == %{"errors" => %{"message" => "Authentication Failed"}}

    end

    test "will create a new user for the spotify id in the database if no user exists", %{conn: conn} do

      refute Accounts.get_user_by_spotify_id(@dummy_profile.id)

      PlaylistPal.Spotify.Mock
      |> expect(:authenticate, fn "valid" -> {:ok, @dummy_access_creds} end)
      |> expect(:profile, fn _ -> {:ok, @dummy_profile} end)


      conn = get(conn, "/v1/authenticate", %{"code" => "valid"})

      user= Accounts.get_user_by_spotify_id(@dummy_profile.id)

      assert user.spotify_id == @dummy_profile.id

      assert json_response(conn, 200) == %{}

    end

  end



#  describe "dumb_auth_tests" do
#
#    PlaylistPal.Spotify.Mock
#      |> expect(:authenticate, fn code -> {:ok, @dummy_access_creds} end)
#
#    res =
#      build_conn()
#      |> SignUpController.dumb_auth(%{"code" => "spotify_auth_code"})
#
#    assert res == {:ok, @dummy_access_creds}
#
#
#  end

end