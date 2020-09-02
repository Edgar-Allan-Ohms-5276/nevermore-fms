defmodule NevermoreWeb.Schema.MatchPenalty do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :classic
  import NevermoreWeb.Errors, only: [handle_errors: 1]
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias NevermoreWeb.Resolvers

  object :match_penalty_page do
    field :entries, list_of(:match_penalty)
    field :page_number, :integer
    field :page_size, :integer
    field :total_pages, :integer
    field :total_entries, :integer
  end

  node object(:match_penalty) do
    field :type, :string
    field :occurred_at, :datetime
    field :schedule, :schedule, resolve: dataloader(Nevermore.Repo)
    field :scheduled_match, :scheduled_match, resolve: dataloader(Nevermore.Repo)
    field :match, :match, resolve: dataloader(Nevermore.Repo)
    field :alliance, :alliance, resolve: dataloader(Nevermore.Repo)
    field :inserted_at, :datetime
    field :updated_at, :datetime
  end

  object :match_penalty_queries do
    @desc "Retrieves all match penalties within the DB, based on the arguments."
    field :match_penalties, :match_penalty_page do
      arg(:id, :id)
      arg(:type, :string)
      arg(:occurred_at, :datetime)
      arg(:schedule, :id)
      arg(:scheduled_match, :id)
      arg(:match, :id)
      arg(:alliance, :id)
      arg(:inserted_at, :datetime)
      arg(:updated_at, :datetime)
      arg(:page, :integer, default_value: 1)
      arg(:page_limit, :integer, default_value: 20)

      resolve(
        handle_errors(
          parsing_node_ids(&Resolvers.MatchPenalty.list_match_penalties/2,
            id: :match_penalty,
            schedule: :schedule,
            scheduled_match: :scheduled_match,
            match: :match,
            alliance: :alliance
          )
        )
      )
    end
  end

  object :match_penalty_mutations do
    # ------------------------------------------------------------------------------------------------------
    # ----------------------------------------Station Assignment Actions------------------------------------
    # ------------------------------------------------------------------------------------------------------
    @desc "Creates a new match penalty."
    field :create_match_penalty, type: :match_penalty do
      arg(:type, :string)
      arg(:occurred_at, :datetime)
      arg(:schedule, :id)
      arg(:scheduled_match, :id)
      arg(:match, :id)
      arg(:alliance, :id)
      arg(:inserted_at, :datetime)
      arg(:updated_at, :datetime)

      resolve(
        handle_errors(
          parsing_node_ids(&Resolvers.MatchPenalty.create_match_penalty/2,
            schedule: :schedule,
            scheduled_match: :scheduled_match,
            match: :match,
            alliance: :alliance
          )
        )
      )
    end

    @desc "Updates a match penalty."
    field :update_match_penalty, type: :match_penalty do
      arg(:id, non_null(:id))
      arg(:type, :string)
      arg(:occurred_at, :datetime)
      arg(:schedule, :id)
      arg(:scheduled_match, :id)
      arg(:match, :id)
      arg(:alliance, :id)
      arg(:inserted_at, :datetime)
      arg(:updated_at, :datetime)

      resolve(
        handle_errors(
          parsing_node_ids(&Resolvers.MatchPenalty.update_match_penalty/2,
            id: :match_penalty,
            schedule: :schedule,
            scheduled_match: :scheduled_match,
            match: :match,
            alliance: :alliance
          )
        )
      )
    end

    @desc "Deletes a match penalty."
    field :delete_match_penalty, type: :match_penalty do
      arg(:id, non_null(:id))

      resolve(
        handle_errors(
          parsing_node_ids(&Resolvers.MatchPenalty.delete_match_penalty/2, id: :match_penalty)
        )
      )
    end
  end
end
