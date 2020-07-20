defmodule Nevermore.Repo.Migrations.CreateSchedulesMatches do
  use Ecto.Migration

  def change do
    create table(:scheduled_matches) do
      add :scheduled_start, :naive_datetime
      add :notes, :string
      add :schedule_id, references(:schedules, on_delete: :nothing)
      add :red_station_id, references(:station_assignments, on_delete: :nothing)
      add :blue_station_id, references(:station_assignments, on_delete: :nothing)

      timestamps()
    end

    create index(:scheduled_matches, [:schedule_id])
    create index(:scheduled_matches, [:red_station_id])
    create index(:scheduled_matches, [:blue_station_id])
  end
end
