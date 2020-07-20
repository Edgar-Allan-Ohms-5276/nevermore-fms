defmodule NevermoreWeb.Schema.StationAssignment do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :classic
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

  node object(:station_assignment) do
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
      arg(:id, :id)
      arg(:side, :side)
      arg(:alliance, :id)
      arg(:station_one, :id)
      arg(:station_two, :id)
      arg(:station_three, :id)
      arg(:notes, :string)
      arg(:page, :integer, default_value: 1)
      arg(:page_limit, :integer, default_value: 20)

      resolve(
        handle_errors(
          parsing_node_ids(&Resolvers.StationAssignment.list_station_assignments/2,
            id: :station_assignment,
            alliance: :alliance,
            station_one: :team,
            station_two: :team,
            station_three: :team
          )
        )
      )
    end
  end

  object :station_assignment_mutations do
    # ------------------------------------------------------------------------------------------------------
    # ----------------------------------------Station Assignment Actions------------------------------------
    # ------------------------------------------------------------------------------------------------------
    @desc "Creates a new station assignment."
    field :create_station_assignment, type: :station_assignment do
      arg(:side, :side)
      arg(:alliance, :id)
      arg(:station_one, :id)
      arg(:station_two, :id)
      arg(:station_three, :id)
      arg(:notes, :string)

      resolve(
        handle_errors(
          parsing_node_ids(&Resolvers.StationAssignment.create_station_assignment/2,
            alliance: :alliance,
            station_one: :team,
            station_two: :team,
            station_three: :team
          )
        )
      )
    end

    @desc "Updates a station assignment."
    field :update_station_assignment, type: :station_assignment do
      arg(:id, non_null(:id))
      arg(:side, :side)
      arg(:alliance, :id)
      arg(:station_one, :id)
      arg(:station_two, :id)
      arg(:station_three, :id)
      arg(:notes, :string)

      resolve(
        handle_errors(
          parsing_node_ids(&Resolvers.StationAssignment.update_station_assignment/2,
            id: :station_assignment,
            alliance: :alliance,
            station_one: :team,
            station_two: :team,
            station_three: :team
          )
        )
      )
    end

    @desc "Deletes a station assignment."
    field :delete_station_assignment, type: :station_assignment do
      arg(:id, non_null(:integer))

      resolve(
        handle_errors(
          parsing_node_ids(&Resolvers.StationAssignment.delete_station_assignment/2,
            id: :station_assignment
          )
        )
      )
    end
  end
end
