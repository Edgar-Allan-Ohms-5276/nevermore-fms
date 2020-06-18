defmodule NevermoreWeb.Schema.Schedule do
  use Absinthe.Schema.Notation
  import NevermoreWeb.Errors, only: [handle_errors: 1]
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias NevermoreWeb.Resolvers

  object :schedule do
    field :id, :integer
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
    field :schedules, list_of(:schedule) do
      arg(:id, :integer)
      arg(:name, :string)
      arg(:notes, :string)
      resolve(handle_errors(&Resolvers.Schedule.list_schedules/3))
    end
  end

  object :schedule_mutations do
    # ------------------------------------------------------------------------------------------------------
    # ----------------------------------------Schedule Actions----------------------------------------------
    # ------------------------------------------------------------------------------------------------------
    @desc "Creates a new schedule."
    field :create_schedule, type: :schedule do
      arg :name, :string
      arg :notes, :string
      resolve(handle_errors(&Resolvers.Schedule.create_schedule/3))
    end

    @desc "Updates a schedule."
    field :update_schedule, type: :schedule do
      arg :id, :integer
      arg :name, :string
      arg :notes, :string
      resolve(handle_errors(&Resolvers.Schedule.update_schedule/3))
    end

    @desc "Deletes a schedule."
    field :delete_schedule, type: :schedule do
      arg :id, non_null(:integer)
      resolve(handle_errors(&Resolvers.Schedule.delete_schedule/3))
    end
  end
end
