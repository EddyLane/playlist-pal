defmodule ElixirElmBootstrap.UserController do

    use ElixirElmBootstrap.Web, :controller
    alias ElixirElmBootstrap.User
    import ElixirElmBootstrap.AuthErrorHandler

#    plug :allow_access when action in [:show]
#
#    def allow_access(conn, %{"id" => id = nil}) do
#       authenticated_user = Guardian.Plug.current_resource(conn)
#       user = Repo.get(User, id)
#
#       if user.id != authenticated_user.id do
#         unauthenticated(conn, :user_not_authed)
#       end
#
#       allow_access(conn, :ok)
#    end
#
#    def allow_access(conn, _), do: conn

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

    def show(conn, %{"id" => id}) do

     authenticated_user = Guardian.Plug.current_resource(conn)
     user = Repo.get(User, id)

     if user.id != authenticated_user.id do
       unauthenticated(conn, :user_not_authed)
     end

      user = Repo.get(User, id)
      render conn, "show.html", user: user
    end

end