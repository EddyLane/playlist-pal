defmodule PlaylistPalWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use PlaylistPalWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:bad_request)
    |> render(PlaylistPalWeb.ChangesetView, "error.json", changeset: changeset)
  end

  def call(conn, nil) do
    conn
    |> put_status(:bad_request)
    |> render(PlaylistPalWeb.ErrorView, "404.json", %{})
  end

#  def call(conn, {:error, :not_found}) do
#    conn
#    |> put_status(:not_found)
#    |> render(PlaylistPalWeb.ErrorView, :"404")
#  end
#
#  def call(conn, {:error, :token_not_found}) do
#    conn
#    |> put_status(:not_found)
#    |> render(PlaylistPalWeb.ErrorView, :"404")
#  end

end
