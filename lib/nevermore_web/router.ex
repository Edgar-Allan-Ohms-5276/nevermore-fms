defmodule NevermoreWeb.Router do
  use NevermoreWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :graphql do
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
    plug NevermoreWeb.GraphQL.Context
  end

  scope "/graphql" do
    pipe_through :graphql

    forward "/graphql", Absinthe.Plug, schema: NevermoreWeb.Schema
  end

  forward "/graphiql",
          Absinthe.Plug.GraphiQL,
          schema: NevermoreWeb.Schema,
          socket: NevermoreWeb.UserSocket,
          interface: :simple

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
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: NevermoreWeb.Telemetry
    end
  end
end
