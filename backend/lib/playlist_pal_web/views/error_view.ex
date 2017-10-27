defmodule PlaylistPalWeb.ErrorView do

  use PlaylistPalWeb, :view

  def render("404.json", _assigns) do
    %{errors: %{message: "Not Found"}}
  end

  def render("500.json", _assigns) do
    %{errors: %{message: "Server Error"}}
  end

  def render("auth_failure.json", _assigns) do
    %{errors: %{message: "Authentication Failed"}}
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.json", assigns
  end

end