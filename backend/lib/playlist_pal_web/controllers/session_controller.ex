defmodule PlaylistPalWeb.SessionController do

  use PlaylistPalWeb, :controller
  alias PlaylistPal.Accounts.User

  plug :scrub_params, "user" when action in [:create]

  def create(conn, params = %{}) do

    username = params["user"]["username"] || ""
    user = Repo.one(from(u in User, where: u.username == ^(username)))

    if user do
      changeset = User.login_changeset(user, params["user"])
      if changeset.valid? do

        new_conn = Guardian.Plug.api_sign_in(conn, user)
        jwt = Guardian.Plug.current_token(new_conn)
        {:ok, claims} = Guardian.Plug.claims(new_conn)
        exp = Map.get(claims, "exp")

        new_conn
        |> put_resp_header("authorization", "Bearer #{jwt}")
        |> put_resp_header("x-expires", "#{exp}")
        |> put_status(:created)
        |> render("show.json", user: user)
      else
        conn
        |> put_status(400)
        |> render("error.json", changeset: changeset)
      end
    else
      changeset = User.login_changeset(%User{})
        |> Ecto.Changeset.add_error(:username, "not found")
      conn
      |> put_status(404)
      |> render("error.json", changeset: changeset)
    end
  end


end