defmodule NevermoreWeb.Schema.MatchEvent do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :classic
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

  node object(:match_event) do
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
      arg(:id, :id)
      arg(:occurred_at, :datetime)
      arg(:schedule, :id)
      arg(:scheduled_match, :id)
      arg(:match, :id)
      arg(:station_assignment, :id)
      arg(:alliance, :id)
      arg(:type, :string)
      arg(:alliance_change, :integer)
      arg(:notes, :string)
      arg(:inserted_at, :datetime)
      arg(:updated_at, :datetime)
      arg(:page, :integer, default_value: 1)
      arg(:page_limit, :integer, default_value: 20)
      resolve(handle_errors(&Resolvers.MatchEvent.list_match_events/3))
    end
  end

  object :match_event_mutations do
    # ------------------------------------------------------------------------------------------------------
    # ----------------------------------------Station Assignment Actions------------------------------------
    # ------------------------------------------------------------------------------------------------------
    @desc "Creates a new match event."
    field :create_match_event, type: :match_event do
      arg(:occurred_at, :datetime)
      arg(:schedule, :id)
      arg(:scheduled_match, :id)
      arg(:match, :id)
      arg(:station_assignment, :id)
      arg(:alliance, :id)
      arg(:type, :string)
      arg(:alliance_change, :integer)
      arg(:notes, :string)
      arg(:inserted_at, :datetime)
      arg(:updated_at, :datetime)

      resolve(
        handle_errors(
          parsing_node_ids(&Resolvers.MatchEvent.create_match_event/2,
            schedule: :schedule,
            scheduled_match: :scheduled_match,
            match: :match,
            station_assignment: :station_assignment,
            alliance: :alliance
          )
        )
      )
    end

    @desc "Updates a match event."
    field :update_match_event, type: :match_event do
      arg(:id, non_null(:id))
      arg(:occurred_at, :datetime)
      arg(:schedule, :id)
      arg(:scheduled_match, :id)
      arg(:match, :id)
      arg(:station_assignment, :id)
      arg(:alliance, :id)
      arg(:type, :string)
      arg(:alliance_change, :integer)
      arg(:notes, :string)
      arg(:inserted_at, :datetime)
      arg(:updated_at, :datetime)

      resolve(
        handle_errors(
          parsing_node_ids(&Resolvers.MatchEvent.update_match_event/2,
            id: :match_event,
            schedule: :schedule,
            scheduled_match: :scheduled_match,
            match: :match,
            station_assignment: :station_assignment,
            alliance: :alliance
          )
        )
      )
    end

    @desc "Deletes a match event."
    field :delete_match_event, type: :match_event do
      arg(:id, non_null(:id))

      resolve(
        handle_errors(
          parsing_node_ids(&Resolvers.MatchEvent.delete_match_event/2, id: :match_event)
        )
      )
    end
  end
end
