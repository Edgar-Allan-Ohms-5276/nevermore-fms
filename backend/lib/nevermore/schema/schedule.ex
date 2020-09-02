defmodule Nevermore.Schedule do
  use Ecto.Schema
  import Ecto.Changeset

  schema "schedules" do
    field :name, :string
    field :notes, :string

    timestamps()
  end

  @doc false
  def changeset(schedule, attrs) do
    schedule
    |> cast(attrs, [:name, :notes])
  end
end
