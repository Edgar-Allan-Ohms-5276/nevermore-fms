defmodule NevermoreWeb.Schema.Schedule do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :classic
  import NevermoreWeb.Errors, only: [handle_errors: 1]
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias NevermoreWeb.Resolvers

  object :schedule_page do
    field :entries, list_of(:schedule)
    field :page_number, :integer
    field :page_size, :integer
    field :total_pages, :integer
    field :total_entries, :integer
  end

  node object(:schedule) do
    field :name, :string
    field :teams, list_of(:team), resolve: dataloader(Nevermore.Repo)
    field :scheduled_matches, list_of(:scheduled_match), resolve: dataloader(Nevermore.Repo)
    field :matches, list_of(:match), resolve: dataloader(Nevermore.Repo)
    field :notes, :string
    field :inserted_at, :datetime
    field :updated_at, :datetime
  end

  object :schedule_queries do
    @desc "Retrieves all schedules within the DB, based on the arguments."
    field :schedules, :schedule_page do
      arg(:id, :id)
      arg(:name, :string)
      arg(:notes, :string)
      arg(:page, :integer, default_value: 1)
      arg(:page_limit, :integer, default_value: 20)

      resolve(
        handle_errors(parsing_node_ids(&Resolvers.Schedule.list_schedules/2, id: :schedule))
      )
    end
  end

  object :schedule_mutations do
    # ------------------------------------------------------------------------------------------------------
    # ----------------------------------------Schedule Actions----------------------------------------------
    # ------------------------------------------------------------------------------------------------------
    @desc "Creates a new schedule."
    field :create_schedule, type: :schedule do
      arg(:name, :string)
      arg(:notes, :string)
      resolve(handle_errors(&Resolvers.Schedule.create_schedule/3))
    end

    @desc "Updates a schedule."
    field :update_schedule, type: :schedule do
      arg(:id, non_null(:id))
      arg(:name, :string)
      arg(:notes, :string)

      resolve(
        handle_errors(parsing_node_ids(&Resolvers.Schedule.update_schedule/2, id: :schedule))
      )
    end

    @desc "Deletes a schedule."
    field :delete_schedule, type: :schedule do
      arg(:id, non_null(:id))

      resolve(
        handle_errors(parsing_node_ids(&Resolvers.Schedule.delete_schedule/2, id: :schedule))
      )
    end
  end
end
