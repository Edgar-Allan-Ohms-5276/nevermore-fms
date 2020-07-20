defmodule Nevermore.StationAssignment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "station_assignments" do
    field :notes, :string
    field :side, :string
    belongs_to :alliance, Nevermore.Alliance
    belongs_to :station_one, Nevermore.StationAssignment
    belongs_to :station_two, Nevermore.StationAssignment
    belongs_to :station_three, Nevermore.StationAssignment

    timestamps()
  end

  @doc false
  def changeset(station_assignment, attrs) do
    station_assignment
    |> cast(attrs, [:side, :notes])
  end
end
