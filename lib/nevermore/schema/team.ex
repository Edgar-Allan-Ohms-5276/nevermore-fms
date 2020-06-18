defmodule Nevermore.Team do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teams" do
    field :logo_url, :string
    field :name, :string
    field :notes, :string
    field :song_url, :string
    has_many :match_penalties, Nevermore.MatchPenalty
    many_to_many :alliances, Nevermore.Alliance, join_through: "alliance_teams"

    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :logo_url, :song_url, :notes])
  end
end
