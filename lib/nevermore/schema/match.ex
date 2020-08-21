defmodule Nevermore.Match do
  use Ecto.Schema
  import Ecto.Changeset

  schema "matches" do
    field :end_time, :naive_datetime
    field :notes, :string
    field :final, :boolean
    field :start_time, :naive_datetime
    belongs_to :schedule, Nevermore.Schedule
    belongs_to :scheduled_match, Nevermore.ScheduledMatch

    timestamps()
  end

  @doc false
  def changeset(match, attrs) do
    match
    |> cast(attrs, [:start_time, :end_time, :notes])
  end
end
