defmodule PlaylistPalWeb.Router do

  use PlaylistPalWeb.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  pipeline :browser_session do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  pipeline :authenticate_user do
    plug Guardian.Plug.EnsureAuthenticated, handler: PlaylistPal.AuthErrorHandler
  end

  scope "/", PlaylistPalWeb do
    pipe_through [:browser, :browser_session] # Use the default browser stack

    get "/login", SessionController, :new, as: :login
    post "/login", SessionController, :create, as: :login
    delete "/logout", SessionController, :delete, as: :logout
    get "/logout", SessionController, :delete, as: :logout

    get "/", PageController, :index
    resources "/users", UserController, only: [:new, :create], param: "username"

  end

  scope "/manage", PlaylistPalWeb do
    pipe_through [:browser, :browser_session, :authenticate_user] # Use the default browser stack
    resources "/users", UserController, only: [:show]
  end

  scope "/", PlaylistPalWeb do
    pipe_through [:browser, :browser_session, :authenticate_user] # Use the default browser stack
    get "/app", PageController, :app
  end

  scope "/new", PlaylistPalWeb do
    pipe_through [:browser, :browser_session]
    get "/app", PageController, :app
  end

   scope "/api", PlaylistPalWeb.API do

     pipe_through [:api, :browser_session, :authenticate_user]
     resources "/events", EventController, except: [:new, :edit]

   end

   scope "/api", PlaylistPalWeb.API do

     pipe_through [:api, :browser_session]
     get "/token", SessionController, :show
     post "/login", SessionController, :create, as: :login
     post "/users", UserController, :create, as: :register

   end
end
