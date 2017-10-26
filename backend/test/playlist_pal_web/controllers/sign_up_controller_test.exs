defmodule PlaylistPalWeb.SignUpControllerTest do

  use ExUnit.Case, async: true
  use PlaylistPalWeb.ConnCase

  alias Spotify.Authorization


  #alias PlaylistPalWeb.SignUpController

  #import Mox

  #@dummy_access_creds %Spotify.Credentials{access_token: "access_token", refresh_token: "refresh_token"}

  test "action that redirects to spotify oauth", %{conn: conn} do
    conn = get(conn, "/v1/sign-up")
    assert redirected_to(conn, :found) == Authorization.url
  end

  describe "authenticate action" do

    test "will 404 if no code is supplied", %{conn: conn} do
      conn = get(conn, "/v1/authenticate")
      assert json_response(conn, :bad_request) == %{"errors" => %{"message" => "Not Found"}}
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