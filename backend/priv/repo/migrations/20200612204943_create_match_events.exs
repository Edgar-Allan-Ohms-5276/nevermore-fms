defmodule Nevermore.Repo.Migrations.CreateMatchEvents do
  use Ecto.Migration

  def change do
    create table(:match_events) do
      add :occurred_at, :naive_datetime
      add :type, :string
      add :alliance_change, :integer
      add :notes, :string
      add :schedule_id, references(:schedules, on_delete: :nothing)
      add :scheduled_match_id, references(:scheduled_matches, on_delete: :nothing)
      add :match_id, references(:matches, on_delete: :nothing)
      add :station_assignment_id, references(:station_assignments, on_delete: :nothing)
      add :alliance_id, references(:alliances, on_delete: :nothing)

      timestamps()
    end

    create index(:match_events, [:schedule_id])
    create index(:match_events, [:scheduled_match_id])
    create index(:match_events, [:match_id])
    create index(:match_events, [:station_assignment_id])
    create index(:match_events, [:alliance_id])
  end
end
