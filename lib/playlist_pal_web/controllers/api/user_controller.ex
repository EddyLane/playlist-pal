defmodule PlaylistPalWeb.API.UserController do

  use PlaylistPalWeb, :controller

  alias PlaylistPal.Accounts
  alias PlaylistPal.Accounts.User

  import PlaylistPal.AuthErrorHandler
  import Guardian.Plug

  action_fallback PlaylistPalWeb.FallbackController

  def create(conn, %{"user" => user_params}) do

    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do

      authed_conn = api_sign_in(conn, user)
      jwt = current_token(authed_conn)
      {:ok, claims} = Guardian.Plug.claims(authed_conn)
      exp = Map.get(claims, "exp")

      authed_conn
        |> put_status(:created)
        |> put_resp_header("location", user_path(authed_conn, :show, user))
        |> put_resp_header("authorization", "Bearer #{jwt}")
        |> put_resp_header("x-expires", "#{exp}")
        |> render("show.json", user: user)

    end

  end

end