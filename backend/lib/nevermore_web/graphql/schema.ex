defmodule NevermoreWeb.GraphQL do
  use Absinthe.Schema
  use Absinthe.Relay.Schema, :classic

  alias NevermoreWeb.GraphQL

  # Import Types and Handlers
  import_types(GraphQL.Types)
  import_types(GraphQL.Team)
  import_types(GraphQL.Schedule)
  import_types(GraphQL.Alliance)
  import_types(GraphQL.StationAssignment)
  import_types(GraphQL.ScheduledMatch)
  import_types(GraphQL.Match)
  import_types(GraphQL.MatchEvent)
  import_types(GraphQL.MatchPenalty)
  import_types(GraphQL.Field)
  import_types(GraphQL.Driverstation)
  import_types(GraphQL.User)
  import_types(GraphQL.Network)

  import_types(GraphQL.Node)

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
