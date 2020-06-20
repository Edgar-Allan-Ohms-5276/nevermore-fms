defmodule NevermoreWeb.Schema.ScheduledMatch do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :classic
  import NevermoreWeb.Errors, only: [handle_errors: 1]
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias NevermoreWeb.Resolvers

  object :scheduled_match_page do
    field :entries, list_of(:scheduled_match)
    field :page_number, :integer
    field :page_size, :integer
    field :total_pages, :integer
    field :total_entries, :integer
  end

  node object(:scheduled_match) do
    field :schedule, :schedule, resolve: dataloader(Nevermore.Repo)
    field :red_station, :station_assignment, resolve: dataloader(Nevermore.Repo)
    field :blue_station, :station_assignment, resolve: dataloader(Nevermore.Repo)
    field :match_penalties, list_of(:match_penalty), resolve: dataloader(Nevermore.Repo)
    field :match_events, list_of(:match_event), resolve: dataloader(Nevermore.Repo)
    field :scheduled_start, :datetime
    field :notes, :string
    field :inserted_at, :datetime
    field :updated_at, :datetime
  end

  object :scheduled_match_queries do
    @desc "Retrieves all scheduled matches within the DB, based on the arguments."
    field :scheduled_matches, :scheduled_match_page do
      arg(:id, :id)
      arg(:schedule, :id)
      arg(:red_station, :id)
      arg(:blue_station, :id)
      arg(:scheduled_start, :datetime)
      arg(:notes, :string)
      arg(:page, non_null(:integer))
      arg(:page_limit, non_null(:integer))

      resolve(
        handle_errors(
          parsing_node_ids(&Resolvers.ScheduledMatch.list_scheduled_matches/2,
            id: :scheduled_match,
            schedule: :schedule,
            red_station: :station_assignment
          )
        )
      )
    end
  end

  object :scheduled_match_mutations do
    # ------------------------------------------------------------------------------------------------------
    # ----------------------------------------Scheduled Match Actions------------------------------------
    # ------------------------------------------------------------------------------------------------------
    @desc "Creates a new scheduled match."
    field :create_scheduled_match, type: :scheduled_match do
      arg(:schedule, :id)
      arg(:red_station, :id)
      arg(:blue_station, :id)
      arg(:scheduled_start, :datetime)
      arg(:notes, :string)

      resolve(
        handle_errors(
          parsing_node_ids(&Resolvers.ScheduledMatch.create_scheduled_match/2,
            schedule: :schedule,
            red_station: :station_assignment,
            blue_station: :station_assignment
          )
        )
      )
    end

    @desc "Updates a scheduled match."
    field :update_scheduled_match, type: :scheduled_match do
      arg(:id, non_null(:id))
      arg(:schedule, :id)
      arg(:red_station, :id)
      arg(:blue_station, :id)
      arg(:scheduled_start, :datetime)
      arg(:notes, :string)

      resolve(
        handle_errors(
          parsing_node_ids(&Resolvers.ScheduledMatch.update_scheduled_match/2,
            id: :scheduled_match,
            schedule: :schedule,
            red_station: :station_assignment,
            blue_station: :station_assignment
          )
        )
      )
    end

    @desc "Deletes a scheduled match."
    field :delete_scheduled_match, type: :scheduled_match do
      arg(:id, non_null(:id))

      resolve(
        handle_errors(
          parsing_node_ids(&Resolvers.ScheduledMatch.delete_scheduled_match/2,
            id: :scheduled_match
          )
        )
      )
    end
  end
end
