defmodule NevermoreWeb.Router do
  use NevermoreWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", NevermoreWeb do
    pipe_through [:api]

    get "/api", PageController, :index
  end
end
