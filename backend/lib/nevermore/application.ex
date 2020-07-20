defmodule Nevermore.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Nevermore.Repo,
      # Start the Telemetry supervisor
      NevermoreWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Nevermore.PubSub},
      # Start the Endpoint (http/https)
      NevermoreWeb.Endpoint,
      # Subscription Socket
      {Absinthe.Subscription, NevermoreWeb.Endpoint},
      # Start the Field
      Nevermore.Field,
      # Start Field Supervisor
      {DynamicSupervisor, strategy: :one_for_one, name: Nevermore.Field.DynamicSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Nevermore.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    NevermoreWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
