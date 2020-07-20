defmodule Nevermore.Team do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teams" do
    field :name, :string
    field :logo_url, :string
    field :song_url, :string
    field :sponsors, {:array, :string}
    field :city, :string
    field :state, :string
    field :country, :string
    field :rookie_year, :integer
    field :school, :string
    field :website, :string
    field :notes, :string
    has_many :match_penalties, Nevermore.MatchPenalty
    many_to_many :alliances, Nevermore.Alliance, join_through: "alliance_teams"

    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [
      :id,
      :name,
      :logo_url,
      :song_url,
      :notes,
      :sponsors,
      :city,
      :state,
      :country,
      :rookie_year,
      :school,
      :website
    ])
  end
end
