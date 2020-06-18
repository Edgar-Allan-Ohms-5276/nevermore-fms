defmodule NevermoreWeb.Schema.Match do
  use Absinthe.Schema.Notation
  import NevermoreWeb.Errors, only: [handle_errors: 1]
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias NevermoreWeb.Resolvers

  object :match do
    field :id, :integer
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
    field :matches, list_of(:match) do
      arg :id, :integer
      arg :schedule, :integer
      arg :scheduled_match, :integer
      arg :start_time, :datetime
      arg :end_time, :datetime
      arg :notes, :string
      resolve(handle_errors(&Resolvers.Match.list_matches/3))
    end
  end

  object :match_mutations do
    # ------------------------------------------------------------------------------------------------------
    # ----------------------------------------Scheduled Match Actions------------------------------------
    # ------------------------------------------------------------------------------------------------------
    @desc "Creates a new match."
    field :create_match, type: :match do
      arg :schedule, :integer
      arg :scheduled_match, :integer
      arg :start_time, :datetime
      arg :end_time, :datetime
      arg :notes, :string
      resolve(handle_errors(&Resolvers.Match.create_match/3))
    end

    @desc "Updates a match."
    field :update_match, type: :match do
      arg :id, non_null(:integer)
      arg :schedule, :integer
      arg :scheduled_match, :integer
      arg :start_time, :datetime
      arg :end_time, :datetime
      arg :notes, :string
      resolve(handle_errors(&Resolvers.Match.create_match/3))
    end

    @desc "Deletes a match."
    field :delete_match, type: :match do
      arg :id, non_null(:integer)
      resolve(handle_errors(&Resolvers.Match.delete_match/3))
    end
  end

end
