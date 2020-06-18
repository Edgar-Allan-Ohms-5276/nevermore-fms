defmodule NevermoreWeb.Schema.ScheduledMatch do
  use Absinthe.Schema.Notation
  import NevermoreWeb.Errors, only: [handle_errors: 1]
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias NevermoreWeb.Resolvers

  object :scheduled_match do
    field :id, :integer
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
    field :scheduled_matches, list_of(:scheduled_match) do
      arg(:id, :integer)
      arg(:schedule, :integer)
      arg(:red_station, :integer)
      arg(:blue_station, :integer)
      arg(:match_penalties, :integer)
      arg(:scheduled_start, :datetime)
      arg(:notes, :string)
      resolve(handle_errors(&Resolvers.ScheduledMatch.list_scheduled_matches/3))
    end
  end

  object :scheduled_match_mutations do
    # ------------------------------------------------------------------------------------------------------
    # ----------------------------------------Scheduled Match Actions------------------------------------
    # ------------------------------------------------------------------------------------------------------
    @desc "Creates a new scheduled match."
    field :create_scheduled_match, type: :scheduled_match do
      arg(:schedule, :integer)
      arg(:red_station, :integer)
      arg(:blue_station, :integer)
      arg(:match_penalties, :integer)
      arg(:scheduled_start, :datetime)
      arg(:notes, :string)
      resolve(handle_errors(&Resolvers.ScheduledMatch.create_scheduled_match/3))
    end

    @desc "Updates a scheduled match."
    field :update_scheduled_match, type: :scheduled_match do
      arg(:id, non_null(:integer))
      arg(:schedule, :integer)
      arg(:red_station, :integer)
      arg(:blue_station, :integer)
      arg(:match_penalties, :integer)
      arg(:scheduled_start, :datetime)
      arg(:notes, :string)
      resolve(handle_errors(&Resolvers.ScheduledMatch.update_scheduled_match/3))
    end

    @desc "Deletes a scheduled match."
    field :delete_scheduled_match, type: :scheduled_match do
      arg(:id, non_null(:integer))
      resolve(handle_errors(&Resolvers.ScheduledMatch.delete_scheduled_match/3))
    end
  end
end
