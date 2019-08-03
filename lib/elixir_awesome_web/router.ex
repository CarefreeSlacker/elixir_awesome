defmodule ElixirAwesomeWeb.Router do
  use ElixirAwesomeWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Phoenix.LiveView.Flash
  end

  scope "/", ElixirAwesomeWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/start_refreshing", PageController, :update
    live "/main_page_live", MainPageLive
  end
end
