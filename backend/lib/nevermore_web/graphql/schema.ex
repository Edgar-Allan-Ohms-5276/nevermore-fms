defmodule NevermoreWeb.Schema do
  use Absinthe.Schema
  use Absinthe.Relay.Schema, :classic

  # Import Types and Handlers
  import_types(NevermoreWeb.Schema.Types)
  import_types(NevermoreWeb.Schema.Team)
  import_types(NevermoreWeb.Schema.Schedule)
  import_types(NevermoreWeb.Schema.Alliance)
  import_types(NevermoreWeb.Schema.StationAssignment)
  import_types(NevermoreWeb.Schema.ScheduledMatch)
  import_types(NevermoreWeb.Schema.Match)
  import_types(NevermoreWeb.Schema.MatchEvent)
  import_types(NevermoreWeb.Schema.MatchPenalty)
  import_types(NevermoreWeb.Schema.Field)
  import_types(NevermoreWeb.Schema.Driverstation)
  import_types(NevermoreWeb.Schema.User)

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

  query do
    node field do
      resolve(fn
        %{type: :alliance, id: id}, _ ->
          {:ok, Nevermore.Repo.get(Nevermore.Alliance, id)}

        %{type: :match, id: id}, _ ->
          {:ok, Nevermore.Repo.get(Nevermore.Match, id)}

        %{type: :match_event, id: id}, _ ->
          {:ok, Nevermore.Repo.get(Nevermore.MatchEvent, id)}

        %{type: :match_penalty, id: id}, _ ->
          {:ok, Nevermore.Repo.get(Nevermore.MatchPenalty, id)}

        %{type: :schedule, id: id}, _ ->
          {:ok, Nevermore.Repo.get(Nevermore.Schedule, id)}

        %{type: :scheduled_match, id: id}, _ ->
          {:ok, Nevermore.Repo.get(Nevermore.ScheduledMatch, id)}

        %{type: :station_assignment, id: id}, _ ->
          {:ok, Nevermore.Repo.get(Nevermore.StationAssigment, id)}

        %{type: :team, id: id}, _ ->
          {:ok, Nevermore.Repo.get(Nevermore.Team, id)}

        %{type: :user, id: id}, _ ->
          {:ok, Nevermore.Repo.get(Nevermore.User, id)}
      end)
    end

    import_fields(:team_queries)

    import_fields(:schedule_queries)

    import_fields(:alliance_queries)

    import_fields(:station_assignment_queries)

    import_fields(:scheduled_match_queries)

    import_fields(:match_queries)

    import_fields(:match_event_queries)

    import_fields(:match_penalty_queries)

    import_fields(:field_queries)

    import_fields(:driverstation_queries)
  end

  mutation do
    import_fields(:team_mutations)

    import_fields(:schedule_mutations)

    import_fields(:alliance_mutations)

    import_fields(:station_assignment_mutations)

    import_fields(:scheduled_match_mutations)

    import_fields(:match_mutations)

    import_fields(:match_event_mutations)

    import_fields(:match_penalty_mutations)

    import_fields(:field_mutations)

    import_fields(:driverstation_mutations)

    import_fields(:user_mutations)
  end

  subscription do
    import_fields(:field_subscriptions)

    import_fields(:driverstation_subscriptions)
  end

  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(Nevermore.Repo, Nevermore.Repo.data())

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
