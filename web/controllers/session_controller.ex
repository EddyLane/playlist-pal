defmodule ElixirElmBootstrap.SessionController do

  use ElixirElmBootstrap.Web, :controller
  alias ElixirElmBootstrap.User
#
#  plug :scrub_params, "user" when action in [:create]
#  plug :action

  def new(conn, params) do
    changeset = User.login_changeset(%User{})
    render(conn, ElixirElmBootstrap.SessionView, "new.html", changeset: changeset)
  end

  def create(conn, params = %{}) do

    username = params["user"]["username"] || ""
    user = Repo.one(from u in User, where: u.username == ^username)

    if user do
      changeset = User.login_changeset(user, params["user"])
      if changeset.valid? do
        conn
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
  
end