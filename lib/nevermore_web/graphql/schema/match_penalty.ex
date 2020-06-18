defmodule NevermoreWeb.Schema.MatchPenalty do
  use Absinthe.Schema.Notation
  import NevermoreWeb.Errors, only: [handle_errors: 1]
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias NevermoreWeb.Resolvers

  object :match_penalty do
    field :id, :integer
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
    field :match_penalties, list_of(:match_penalty) do
      arg :id, :integer
      arg :type, :string
      arg :occurred_at, :datetime
      arg :schedule, :integer
      arg :scheduled_match, :integer
      arg :match, :integer
      arg :alliance, :integer
      arg :inserted_at, :datetime
      arg :updated_at, :datetime
      resolve(handle_errors(&Resolvers.MatchPenalty.list_match_penalties/3))
    end
  end

  object :match_penalty_mutations do
    # ------------------------------------------------------------------------------------------------------
    # ----------------------------------------Station Assignment Actions------------------------------------
    # ------------------------------------------------------------------------------------------------------
    @desc "Creates a new match penalty."
    field :create_match_penalty, type: :match_penalty do
      arg :type, :string
      arg :occurred_at, :datetime
      arg :schedule, :integer
      arg :scheduled_match, :integer
      arg :match, :integer
      arg :alliance, :integer
      arg :inserted_at, :datetime
      arg :updated_at, :datetime
      resolve(handle_errors(&Resolvers.MatchPenalty.create_match_penalty/3))
    end

    @desc "Updates a match penalty."
    field :update_match_penalty, type: :match_penalty do
      arg :id, non_null(:integer)
      arg :type, :string
      arg :occurred_at, :datetime
      arg :schedule, :integer
      arg :scheduled_match, :integer
      arg :match, :integer
      arg :alliance, :integer
      arg :inserted_at, :datetime
      arg :updated_at, :datetime
      resolve(handle_errors(&Resolvers.MatchPenalty.update_match_penalty/3))
    end

    @desc "Deletes a match penalty."
    field :delete_match_penalty, type: :match_penalty do
      arg :id, non_null(:integer)
      resolve(handle_errors(&Resolvers.MatchPenalty.delete_match_penalty/3))
    end
  end

end
