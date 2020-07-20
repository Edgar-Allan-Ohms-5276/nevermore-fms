defmodule Nevermore.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :text
      add :logo_url, :text
      add :song_url, :text
      add :sponsors, {:array, :text}
      add :city, :text
      add :state, :text
      add :country, :string
      add :rookie_year, :integer
      add :school, :text
      add :website, :text
      add :notes, :text

      timestamps()
    end
  end
end
