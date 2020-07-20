defmodule Nevermore.Alliance do
  use Ecto.Schema
  import Ecto.Changeset

  schema "alliances" do
    field :name, :string
    field :notes, :string
    many_to_many :teams, Nevermore.Team, join_through: "alliance_teams"

    timestamps()
  end

  @doc false
  def changeset(alliance, attrs) do
    alliance
    |> cast(attrs, [:name, :notes])
  end
end
