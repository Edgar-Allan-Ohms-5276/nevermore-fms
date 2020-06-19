defmodule NevermoreWeb.Schema do
  use Absinthe.Schema

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

  query do
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
