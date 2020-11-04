defmodule NevermoreWeb.GraphQL.Team do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :classic
  import NevermoreWeb.Errors, only: [handle_errors: 1]
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias NevermoreWeb.Resolvers

  object :team_page do
    field :entries, list_of(:team)
    field :page_number, :integer
    field :page_size, :integer
    field :total_pages, :integer
    field :total_entries, :integer
  end

  node object(:team) do
    field :name, :string
    field :team_number, :integer
    field :logo_url, :string
    field :song_url, :string
    field :sponsors, list_of(:string)
    field :city, :string
    field :state, :string
    field :country, :string
    field :rookie_year, :integer
    field :school, :string
    field :website, :string
    field :notes, :string
    field :match_penalties, list_of(:match_penalty), resolve: dataloader(Nevermore.Repo)
    field :alliances, list_of(:alliance), resolve: dataloader(Nevermore.Repo)
    field :inserted_at, :datetime
    field :updated_at, :datetime
  end

  object :team_queries do
    @desc "Retrieves all teams within the DB, based on the arguments."
    field :teams, :team_page do
      arg(:id, :id)
      arg(:name, :string)
      arg(:logo_url, :string)
      arg(:song_url, :string)
      arg(:sponsors, list_of(:string))
      arg(:city, :string)
      arg(:state, :string)
      arg(:country, :string)
      arg(:rookie_year, :integer)
      arg(:school, :string)
      arg(:website, :string)
      arg(:notes, :string)
      arg(:page, :integer, default_value: 1)
      arg(:page_limit, :integer, default_value: 20)

      resolve(handle_errors(parsing_node_ids(&Resolvers.Team.list_teams/2, id: :team)))
    end
  end

  object :team_mutations do
    # ------------------------------------------------------------------------------------------------------
    # ----------------------------------------Team Actions--------------------------------------------------
    # ------------------------------------------------------------------------------------------------------
    @desc "Imports all teams from The Blue Alliance"
    field :import_teams_from_online, type: :success do
      resolve(fn _, _ ->
        Nevermore.Repo.delete_all(Nevermore.Team)
        teams = NevermoreWeb.Utils.TBAImport.get_all_teams()

        Enum.each(teams, fn team ->
          args = %{
            id: team["team_number"],
            name: team["nickname"],
            sponsors: String.split(team["name"], "/"),
            city: team["city"],
            state: team["state_prov"],
            country: team["country"],
            rookie_year: team["rookie_year"],
            school: team["school_name"],
            website: team["website"]
          }

          Nevermore.Repo.insert(Nevermore.Team.changeset(%Nevermore.Team{}, args))
        end)

        {:ok,
         %{
           successful: true
         }}
      end)
    end

    @desc "Creates a new team."
    field :create_team, type: :team do
      arg(:id, non_null(:id))
      arg(:name, :string)
      arg(:logo_url, :string)
      arg(:song_url, :string)
      arg(:sponsors, list_of(:string))
      arg(:city, :string)
      arg(:state, :string)
      arg(:country, :string)
      arg(:rookie_year, :integer)
      arg(:school, :string)
      arg(:website, :string)
      arg(:notes, :string)
      resolve(handle_errors(&Resolvers.Team.create_team/3))
    end

    @desc "Updates a team."
    field :update_team, type: :team do
      arg(:id, non_null(:id))
      arg(:name, :string)
      arg(:logo_url, :string)
      arg(:song_url, :string)
      arg(:sponsors, list_of(:string))
      arg(:city, :string)
      arg(:state, :string)
      arg(:country, :string)
      arg(:rookie_year, :integer)
      arg(:school, :string)
      arg(:website, :string)
      arg(:notes, :string)
      resolve(handle_errors(parsing_node_ids(&Resolvers.Team.update_team/2, id: :team)))
    end

    @desc "Deletes a team."
    field :delete_team, type: :team do
      arg(:id, non_null(:id))
      resolve(handle_errors(parsing_node_ids(&Resolvers.Team.delete_team/2, id: :team)))
    end
  end
end
