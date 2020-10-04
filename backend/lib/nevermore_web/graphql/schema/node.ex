defmodule NevermoreWeb.GraphQL.Node do
  @moduledoc """
  The module `NevermoreWeb.GraphQL.Node` defines the node interfaces used as apart of [GraphQL's Global Object Specification](https://graphql.org/learn/global-object-identification/).
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :classic

    node interface do
      resolve_type(fn
        %{sponsors: _, school: _}, _ ->
          :team

        %{teams: _, name: _}, _ ->
          :alliance

        %{e_stopped: _, station: _}, _ ->
          :driverstation

        %{udp_port: _, event_name: _}, _ ->
          :field

        %{start_time: _, end_time: _, schedule: _}, _ ->
          :match

        %{occurred_at: _, type: _, alliance_change: _}, _ ->
          :match_event

        %{occurred_at: _, type: _}, _ ->
          :match_penalty

        %{scheduled_matches: _, name: _}, _ ->
          :schedule

        %{schedule: _, red_station: _}, _ ->
          :scheduled_match

        %{side: _, station_one: _}, _ ->
          :station_assignment

        %{email: _, name: _}, _ ->
          :user

        _, _ ->
          nil
      end)
    end
end
