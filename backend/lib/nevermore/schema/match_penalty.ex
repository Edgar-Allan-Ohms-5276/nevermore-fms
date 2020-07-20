defmodule Nevermore.MatchPenalty do
  use Ecto.Schema
  import Ecto.Changeset

  schema "match_penalties" do
    field :occurred_at, :naive_datetime
    field :type, :string
    belongs_to :schedule, Nevermore.Schedule
    belongs_to :scheduled_match, Nevermore.ScheduledMatch
    belongs_to :match, Nevermore.Match
    belongs_to :alliance, Nevermore.Alliance
    belongs_to :team, Nevermore.Team

    timestamps()
  end

  @doc false
  def changeset(match_penalty, attrs) do
    match_penalty
    |> cast(attrs, [:type, :occurred_at])
  end
end
