defmodule PlaylistPalWeb.SignUpView do

  use PlaylistPalWeb, :view
  alias PlaylistPalWeb.UserView

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

end
