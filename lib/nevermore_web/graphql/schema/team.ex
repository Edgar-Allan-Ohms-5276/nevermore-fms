defmodule NevermoreWeb.Schema.Team do
  use Absinthe.Schema.Notation
  import NevermoreWeb.Errors, only: [handle_errors: 1]
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias NevermoreWeb.Resolvers

  object :team do
    field :id, :integer
    field :name, :string
    field :logo_url, :string
    field :song_url, :string
    field :match_penalties, list_of(:match_penalty), resolve: dataloader(Nevermore.Repo)
    field :alliances, list_of(:alliance), resolve: dataloader(Nevermore.Repo)
    field :notes, :string
    field :inserted_at, :datetime
    field :updated_at, :datetime
  end

  object :team_queries do
    @desc "Retrieves all teams within the DB, based on the arguments."
    field :teams, list_of(:team) do
      arg :id, :integer
      arg :name, :string
      arg :logo_url, :string
      arg :song_url, :string
      arg :notes, :string
      resolve(handle_errors(&Resolvers.Team.list_teams/3))
    end
  end

  object :team_mutations do
    # ------------------------------------------------------------------------------------------------------
    # ----------------------------------------Team Actions--------------------------------------------------
    # ------------------------------------------------------------------------------------------------------
    @desc "Creates a new team."
    field :create_team, type: :team do
      arg :id, non_null(:integer)
      arg :name, :string
      arg :logo_url, :string
      arg :song_url, :string
      arg :notes, :string
      resolve(handle_errors(&Resolvers.Team.create_team/3))
    end

    @desc "Updates a team."
    field :update_team, type: :team do
      arg :id, non_null(:integer)
      arg :name, :string
      arg :logo_url, :string
      arg :song_url, :string
      arg :notes, :string
      resolve(handle_errors(&Resolvers.Team.update_team/3))
    end

    @desc "Deletes a team."
    field :delete_team, type: :team do
      arg :id, non_null(:integer)
      resolve(handle_errors(&Resolvers.Team.delete_team/3))
    end
  end
end
