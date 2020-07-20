defmodule NevermoreWeb.Schema.Match do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :classic
  import NevermoreWeb.Errors, only: [handle_errors: 1]
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias NevermoreWeb.Resolvers

  object :match_page do
    field :entries, list_of(:match)
    field :page_number, :integer
    field :page_size, :integer
    field :total_pages, :integer
    field :total_entries, :integer
  end

  node object(:match) do
    field :schedule, :schedule, resolve: dataloader(Nevermore.Repo)
    field :scheduled_match, :scheduled_match, resolve: dataloader(Nevermore.Repo)
    field :match_events, list_of(:match_event), resolve: dataloader(Nevermore.Repo)
    field :match_penalties, list_of(:match_penalty), resolve: dataloader(Nevermore.Repo)
    field :start_time, :datetime
    field :end_time, :datetime
    field :notes, :string
    field :inserted_at, :datetime
    field :updated_at, :datetime
  end

  object :match_queries do
    @desc "Retrieves all matches within the DB, based on the arguments."
    field :matches, :match_page do
      arg(:id, :id)
      arg(:schedule, :id)
      arg(:scheduled_match, :integer)
      arg(:start_time, :datetime)
      arg(:end_time, :datetime)
      arg(:notes, :string)
      arg(:page, :integer, default_value: 1)
      arg(:page_limit, :integer, default_value: 20)
      resolve(handle_errors(&Resolvers.Match.list_matches/3))
    end
  end

  object :match_mutations do
    # ------------------------------------------------------------------------------------------------------
    # ----------------------------------------Scheduled Match Actions------------------------------------
    # ------------------------------------------------------------------------------------------------------
    @desc "Creates a new match."
    field :create_match, type: :match do
      arg(:schedule, :id)
      arg(:scheduled_match, :integer)
      arg(:start_time, :datetime)
      arg(:end_time, :datetime)
      arg(:notes, :string)

      resolve(
        handle_errors(parsing_node_ids(&Resolvers.Match.create_match/2, schedule: :schedule))
      )
    end

    @desc "Updates a match."
    field :update_match, type: :match do
      arg(:id, non_null(:id))
      arg(:schedule, :integer)
      arg(:scheduled_match, :integer)
      arg(:start_time, :datetime)
      arg(:end_time, :datetime)
      arg(:notes, :string)

      resolve(
        handle_errors(
          parsing_node_ids(&Resolvers.Match.create_match/2, id: :match, schedule: :schedule)
        )
      )
    end

    @desc "Deletes a match."
    field :delete_match, type: :match do
      arg(:id, non_null(:id))
      resolve(handle_errors(parsing_node_ids(&Resolvers.Match.delete_match/2, id: :match)))
    end
  end
end
