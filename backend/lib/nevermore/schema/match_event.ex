defmodule Nevermore.MatchEvent do
  use Ecto.Schema
  import Ecto.Changeset

  schema "match_events" do
    field :alliance_change, :integer
    field :notes, :string
    field :occurred_at, :naive_datetime
    field :type, :string
    belongs_to :schedule, Nevermore.Schedule
    belongs_to :scheduled_match, Nevermore.ScheduledMatch
    belongs_to :match, Nevermore.Match
    belongs_to :station_assignment, Nevermore.StationAssignment
    belongs_to :alliance, Nevermore.Alliance

    timestamps()
  end

  @doc false
  def changeset(match_event, attrs) do
    match_event
    |> cast(attrs, [:occurred_at, :type, :alliance_change, :notes])
  end
end
