defmodule ElixirElmBootstrap.Router do
  use ElixirElmBootstrap.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ElixirElmBootstrap do
    pipe_through :browser # Use the default browser stack

    get "/login", SessionController, :new, as: :login
    post "/login", SessionController, :create, as: :login
    get "/", PageController, :index
    resources "/users", UserController, only: [:new, :create]

  end

  # Other scopes may use custom stacks.
  # scope "/api", ElixirElmBootstrap do
  #   pipe_through :api
  # end
end
