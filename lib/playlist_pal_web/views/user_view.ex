defmodule PlaylistPal.UserView do
  use PlaylistPalWeb.Web, :view
  alias PlaylistPal.User

  def first_name(%User{name: name}) do
    name
    |> String.split(" ")
    |> Enum.at(0)
  end

end