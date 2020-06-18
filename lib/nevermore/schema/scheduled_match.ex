defmodule Nevermore.ScheduledMatch do
  use Ecto.Schema
  import Ecto.Changeset

  schema "scheduled_matches" do
    field :notes, :string
    field :scheduled_start, :naive_datetime
    belongs_to :schedule, Nevermore.Schedule
    belongs_to :red_station, Nevermore.StationAssignment
    belongs_to :blue_station, Nevermore.StationAssignment

    timestamps()
  end

  @doc false
  def changeset(scheduled_match, attrs) do
    scheduled_match
    |> cast(attrs, [:scheduled_start, :notes])
  end
end
