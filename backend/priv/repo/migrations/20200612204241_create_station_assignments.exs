defmodule Nevermore.Repo.Migrations.CreateStationAssignments do
  use Ecto.Migration

  def change do
    create table(:station_assignments) do
      add :side, :string
      add :notes, :string
      add :alliance_id, references(:alliances, on_delete: :nothing)
      add :station_one_id, references(:teams, on_delete: :nothing)
      add :station_two_id, references(:teams, on_delete: :nothing)
      add :station_three_id, references(:teams, on_delete: :nothing)

      timestamps()
    end

    create index(:station_assignments, [:alliance_id])
    create index(:station_assignments, [:station_one_id])
    create index(:station_assignments, [:station_two_id])
    create index(:station_assignments, [:station_three_id])
  end
end
