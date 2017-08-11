defmodule PlaylistPalWeb.Router do

  use PlaylistPalWeb, :router

  pipeline :api do
    plug :accepts, ["json"]

    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.LoadResource
  end

  pipeline :authenticate do
    plug Guardian.Plug.EnsureAuthenticated, handler: PlaylistPal.ApiAuthErrorHandler
  end

   scope "/", PlaylistPalWeb do
     get "/", PageController, :app
   end

  scope "/api", PlaylistPalWeb do
    pipe_through [:api]
    post "/users", UserController, :create, as: :register
    post "/login", SessionController, :create, as: :login
  end

  scope "/api", PlaylistPalWeb do
    pipe_through [:api, :authenticate]
    resources "/playlists", PlaylistController, only: [:create]
  end

end