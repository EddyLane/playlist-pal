defmodule PlaylistPalWeb.API.UserController do

  use PlaylistPalWeb.Web, :controller
  alias PlaylistPal.User
  import PlaylistPal.AuthErrorHandler

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)
    case Repo.insert(changeset) do
      {:ok, user} ->
        new_conn = Guardian.Plug.api_sign_in(conn, user)
        jwt = Guardian.Plug.current_token(new_conn)
        {:ok, claims} = Guardian.Plug.claims(new_conn)
        exp = Map.get(claims, "exp")
        new_conn
        |> Guardian.Plug.sign_in(user, :token, perms: %{default: Guardian.Permissions.max})
        |> put_status(201)
        |> json(%{user: %{user | token: jwt}})

      {:error, changeset} ->
        render conn, "error.json", changeset: changeset
    end
  end
end