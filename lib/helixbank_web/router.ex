defmodule HelixbankWeb.Router do
  use HelixbankWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug HelixBankWeb.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HelixbankWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/home", HomeController, :index

    scope "/user" do
      get "/info", UserController, :info
      get "/new_deposit", UserController, :new_deposit
      post "/make_deposit", UserController, :make_deposit
      get "/new_withdraw", UserController, :new_withdraw
      post "/make_withdraw", UserController, :make_withdraw
      get "/new_transfer", UserController, :new_transfer
      post "/make_transfer", UserController, :make_transfer
    end

    resources "/user", UserController, [:create, :new, :index]
    resources "/session", SessionController, only: [:new, :create, :delete]
  end

  # Other scopes may use custom stacks.
  # scope "/api", HelixbankWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: HelixbankWeb.Telemetry
    end
  end
end
