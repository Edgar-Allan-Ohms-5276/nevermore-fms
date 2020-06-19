defmodule NevermoreWeb.Schema.MatchEvent do
  use Absinthe.Schema.Notation
  import NevermoreWeb.Errors, only: [handle_errors: 1]
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias NevermoreWeb.Resolvers

  object :match_event_page do
    field :entries, list_of(:match_event)
    field :page_number, :integer
    field :page_size, :integer
    field :total_pages, :integer
    field :total_entries, :integer
  end

  object :match_event do
    field :id, :integer
    field :occurred_at, :datetime
    field :schedule, :schedule, resolve: dataloader(Nevermore.Repo)
    field :scheduled_match, :scheduled_match, resolve: dataloader(Nevermore.Repo)
    field :match, :match, resolve: dataloader(Nevermore.Repo)
    field :station_assignment, :station_assignment, resolve: dataloader(Nevermore.Repo)
    field :alliance, :alliance, resolve: dataloader(Nevermore.Repo)
    field :type, :string
    field :alliance_change, :integer
    field :notes, :string
    field :inserted_at, :datetime
    field :updated_at, :datetime
  end

  object :match_event_queries do
    @desc "Retrieves all match events within the DB, based on the arguments."
    field :match_events, :match_event_page do
      arg(:id, :integer)
      arg(:occurred_at, :datetime)
      arg(:schedule, :integer)
      arg(:scheduled_match, :integer)
      arg(:match, :integer)
      arg(:station_assignment, :integer)
      arg(:alliance, :integer)
      arg(:type, :string)
      arg(:alliance_change, :integer)
      arg(:notes, :string)
      arg(:inserted_at, :datetime)
      arg(:updated_at, :datetime)
      arg(:page, non_null(:integer))
      arg(:page_limit, non_null(:integer))
      resolve(handle_errors(&Resolvers.MatchEvent.list_match_events/3))
    end

    @desc "Retrieves a match event by it's ID."
    field :match_event, :match_event do
      arg(:id, non_null(:integer))
      resolve(handle_errors(&Resolvers.MatchEvent.get_match_event/3))
    end
  end

  object :match_event_mutations do
    # ------------------------------------------------------------------------------------------------------
    # ----------------------------------------Station Assignment Actions------------------------------------
    # ------------------------------------------------------------------------------------------------------
    @desc "Creates a new match event."
    field :create_match_event, type: :match_event do
      arg(:occurred_at, :datetime)
      arg(:schedule, :integer)
      arg(:scheduled_match, :integer)
      arg(:match, :integer)
      arg(:station_assignment, :integer)
      arg(:alliance, :integer)
      arg(:type, :string)
      arg(:alliance_change, :integer)
      arg(:notes, :string)
      arg(:inserted_at, :datetime)
      arg(:updated_at, :datetime)
      resolve(handle_errors(&Resolvers.MatchEvent.create_match_event/3))
    end

    @desc "Updates a match event."
    field :update_match_event, type: :match_event do
      arg(:id, non_null(:integer))
      arg(:occurred_at, :datetime)
      arg(:schedule, :integer)
      arg(:scheduled_match, :integer)
      arg(:match, :integer)
      arg(:station_assignment, :integer)
      arg(:alliance, :integer)
      arg(:type, :string)
      arg(:alliance_change, :integer)
      arg(:notes, :string)
      arg(:inserted_at, :datetime)
      arg(:updated_at, :datetime)
      resolve(handle_errors(&Resolvers.MatchEvent.update_match_event/3))
    end

    @desc "Deletes a match event."
    field :delete_match_event, type: :match_event do
      arg(:id, non_null(:integer))
      resolve(handle_errors(&Resolvers.MatchEvent.delete_match_event/3))
    end
  end
end
