defmodule PlaylistPalWeb.SessionController do

  use PlaylistPalWeb, :controller
  alias PlaylistPal.Accounts.User

  plug :scrub_params, "user" when action in [:create]

  def new(conn, params) do
    changeset = User.login_changeset(%User{})
    render(conn, PlaylistPalWeb.SessionView, "new.html", changeset: changeset)
  end

  def create(conn, params = %{}) do

    username = params["user"]["username"] || ""
    user = Repo.one(from u in User, where: u.username == ^username)

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
        |> put_flash(:info, "Logged in.")
        |> Guardian.Plug.sign_in(user, :token, perms: %{ default: Guardian.Permissions.max })
        |> redirect(to: page_path(conn, :index))


      else
        render(conn, "new.html", changeset: changeset)
      end
    else
      changeset = User.login_changeset(%User{}) |> Ecto.Changeset.add_error(:login, "not found")
      render(conn, "new.html", changeset: changeset)
    end
  end

  def delete(conn, _params) do

      jwt = Guardian.Plug.current_token(conn)
      {:ok, claims} = Guardian.Plug.claims(conn)
      Guardian.revoke!(jwt, claims)

    Guardian.Plug.sign_out(conn)
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: page_path(conn, :index))
  end


end