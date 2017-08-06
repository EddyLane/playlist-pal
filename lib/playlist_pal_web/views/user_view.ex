defmodule PlaylistPalWeb.UserView do

  use PlaylistPalWeb, :view

  alias PlaylistPal.Accounts.User

  def first_name(%User{name: name}) do
    name
      |> String.split(" ")
      |> Enum.at(0)
  end

end
