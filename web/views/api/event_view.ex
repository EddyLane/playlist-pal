defmodule ElixirElmBootstrap.API.EventView do

  use ElixirElmBootstrap.Web, :view

  def render("index.json", %{events: events}) do
    %{data: render_many(events, ElixirElmBootstrap.API.EventView, "event.json")}
  end

  def render("show.json", %{event: event}) do
    %{data: render_one(event, ElixirElmBootstrap.API.EventView, "event.json")}
  end

  def render("event.json", %{event: event}) do
    %{id: event.id,
      name: event.name}
  end

end
