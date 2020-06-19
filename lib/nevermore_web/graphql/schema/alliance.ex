defmodule NevermoreWeb.Schema.Alliance do
  use Absinthe.Schema.Notation
  import NevermoreWeb.Errors, only: [handle_errors: 1]
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias NevermoreWeb.Resolvers

  object :alliance_page do
    field :entries, list_of(:alliance)
    field :page_number, :integer
    field :page_size, :integer
    field :total_pages, :integer
    field :total_entries, :integer
  end

  object :alliance do
    field :id, :integer
    field :name, :string
    field :teams, list_of(:team), resolve: dataloader(Nevermore.Repo)
    field :notes, :string
    field :inserted_at, :datetime
    field :updated_at, :datetime
  end

  object :alliance_queries do
    @desc "Retrieves all alliances within the DB, based on the arguments."
    field :alliances, :alliance_page do
      arg(:id, :integer)
      arg(:name, :string)
      arg(:notes, :string)
      arg(:page, non_null(:integer))
      arg(:page_limit, non_null(:integer))
      resolve(handle_errors(&Resolvers.Alliance.list_alliances/3))
    end

    @desc "Retrieves a alliance by it's ID."
    field :alliance, :alliance do
      arg(:id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Alliance.get_alliance/3))
    end
  end

  object :alliance_mutations do
    # ------------------------------------------------------------------------------------------------------
    # ----------------------------------------Alliance Actions----------------------------------------------
    # ------------------------------------------------------------------------------------------------------
    @desc "Creates a new alliance."
    field :create_alliance, type: :alliance do
      arg(:name, :string)
      arg(:teams, list_of(:integer))
      arg(:notes, :string)
      resolve(handle_errors(&Resolvers.Alliance.create_alliance/3))
    end

    @desc "Updates a alliance."
    field :update_alliance, type: :alliance do
      arg(:id, non_null(:integer))
      arg(:name, :string)
      arg(:teams, list_of(:integer))
      arg(:notes, :string)
      resolve(handle_errors(&Resolvers.Alliance.update_alliance/3))
    end

    @desc "Deletes a alliance."
    field :delete_alliance, type: :alliance do
      arg(:id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Alliance.delete_alliance/3))
    end
  end
end
