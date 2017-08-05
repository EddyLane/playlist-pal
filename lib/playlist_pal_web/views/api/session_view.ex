defmodule PlaylistPalWeb.API.SessionView do
  use PlaylistPalWeb.Web, :view

 def render("errorr.json", %{changeset: changeset}) do
    errors = Enum.map(changeset.errors, fn {field, detail} ->
      %{
        field: field,
        error: render_detail(detail)
      }
    end)

    %{errors: errors}
  end

  def render_detail({message, values}) do
    Enum.reduce values, message, fn {k, v}, acc ->
      String.replace(acc, "%{#{k}}", to_string(v))
    end
  end

  def render_detail(message) do
    message
  end

end