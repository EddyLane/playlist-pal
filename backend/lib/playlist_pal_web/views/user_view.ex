defmodule PlaylistPalWeb.UserView do

  use PlaylistPalWeb, :view
  alias PlaylistPalWeb.UserView

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{spotify_id: user.spotify_id}
  end

end
