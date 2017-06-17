defmodule ElixirElmBootstrap.UserController do

    use ElixirElmBootstrap.Web, :controller
    alias ElixirElmBootstrap.User
    import ElixirElmBootstrap.AuthErrorHandler


    def new(conn, _params) do
      changeset = User.changeset(%User{})
      render conn, "new.html", changeset: changeset
    end

    def create(conn, %{"user" => user_params}) do

      changeset = User.registration_changeset(%User{}, user_params)

      case Repo.insert(changeset) do
        {:ok, user} ->
          conn
          |> Guardian.Plug.sign_in(user, :token, perms: %{ default: Guardian.Permissions.max })
          |> put_flash(:info, "#{user.name} created!")
          |> redirect(to: page_path(conn, :index))
        {:error, changeset} ->
          render(conn, "new.html", changeset: changeset)
      end

    end

    def show(conn, %{"id" => username}) do

     authenticated_user = Guardian.Plug.current_resource(conn)

     user = Repo.get_by(User, username: username)

     if user.id != authenticated_user.id do
       unauthenticated(conn, :user_not_authed)
     end

      render conn, "show.html", user: user
    end

end