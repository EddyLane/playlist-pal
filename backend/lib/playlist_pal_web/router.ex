defmodule PlaylistPalWeb.Router do

  use PlaylistPalWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :spotify do
    plug :accepts, ["html"]
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/v1", PlaylistPalWeb do
    pipe_through [:browser, :spotify]

    get "/sign-up", SignUpController, :sign_up
    get "/authenticate", SignUpController, :authenticate


  end

  scope "/v1", PlaylistPalWeb do
    pipe_through [:api]

    post "/login-token", SignUpController, :login_token
  end


end
