defmodule PlaylistPalWeb.SignUpControllerTest do

  use ExUnit.Case, async: false
  use PlaylistPalWeb.ConnCase

  alias PlaylistPalWeb.SignUpController

  import Mox

  @dummy_access_creds %Spotify.Credentials{access_token: "access_token", refresh_token: "refresh_token"}

  describe "dumb_auth_tests" do

    PlaylistPal.Spotify.Mock
    |> expect(:authenticate, fn conn, params -> {:ok, @dummy_access_creds} end)


    conn = build_conn()

    res = SignUpController.dumb_auth(conn, %{})

    assert res == {:ok, @dummy_access_creds}


  end

end