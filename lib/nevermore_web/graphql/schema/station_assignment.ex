defmodule NevermoreWeb.Schema.StationAssignment do
  use Absinthe.Schema.Notation
  import NevermoreWeb.Errors, only: [handle_errors: 1]
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias NevermoreWeb.Resolvers

  object :station_assignment_page do
    field :entries, list_of(:station_assignment)
    field :page_number, :integer
    field :page_size, :integer
    field :total_pages, :integer
    field :total_entries, :integer
  end

  object :station_assignment do
    field :id, :integer
    field :side, :side
    field :alliance, :alliance, resolve: dataloader(Nevermore.Repo)
    field :station_one, :team, resolve: dataloader(Nevermore.Repo)
    field :station_two, :team, resolve: dataloader(Nevermore.Repo)
    field :station_three, :team, resolve: dataloader(Nevermore.Repo)
    field :notes, :string
    field :inserted_at, :datetime
    field :updated_at, :datetime
  end

  enum :side do
    value(:red, as: "r")
    value(:blue, as: "b")
  end

  object :station_assignment_queries do
    @desc "Retrieves all station assignments within the DB, based on the arguments."
    field :station_assignments, :station_assignment_page do
      arg(:id, :integer)
      arg(:side, :side)
      arg(:alliance, :integer)
      arg(:station_one, :integer)
      arg(:station_two, :integer)
      arg(:station_three, :integer)
      arg(:notes, :string)
      arg(:page, non_null(:integer))
      arg(:page_limit, non_null(:integer))
      resolve(handle_errors(&Resolvers.StationAssignment.list_station_assignments/3))
    end

    @desc "Retrieves a station assignment by it's ID."
    field :station_assignment, :station_assignment do
      arg(:id, non_null(:integer))
      resolve(handle_errors(&Resolvers.StationAssignment.get_station_assignment/3))
    end
  end

  object :station_assignment_mutations do
    # ------------------------------------------------------------------------------------------------------
    # ----------------------------------------Station Assignment Actions------------------------------------
    # ------------------------------------------------------------------------------------------------------
    @desc "Creates a new station assignment."
    field :create_station_assignment, type: :station_assignment do
      arg(:side, :side)
      arg(:alliance, :integer)
      arg(:station_one, :integer)
      arg(:station_two, :integer)
      arg(:station_three, :integer)
      arg(:notes, :string)
      resolve(handle_errors(&Resolvers.StationAssignment.create_station_assignment/3))
    end

    @desc "Updates a station assignment."
    field :update_station_assignment, type: :station_assignment do
      arg(:id, non_null(:integer))
      arg(:side, :side)
      arg(:alliance, :integer)
      arg(:station_one, :integer)
      arg(:station_two, :integer)
      arg(:station_three, :integer)
      arg(:notes, :string)
      resolve(handle_errors(&Resolvers.StationAssignment.update_station_assignment/3))
    end

    @desc "Deletes a station assignment."
    field :delete_station_assignment, type: :station_assignment do
      arg(:id, non_null(:integer))
      resolve(handle_errors(&Resolvers.StationAssignment.delete_station_assignment/3))
    end
  end
end
