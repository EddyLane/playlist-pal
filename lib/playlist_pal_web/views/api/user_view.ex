defmodule PlaylistPalWeb.API.UserView do

  use PlaylistPalWeb, :view

  alias PlaylistPal.Accounts.User
  alias PlaylistPalWeb.API.UserView

  def render("index.json", %{ user: user}) do
    %{data: render_many(user, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{name: user.name,
      username: user.username}
  end

end
