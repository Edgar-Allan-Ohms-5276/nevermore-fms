defmodule Nevermore.Repo.Migrations.CreateAccountsUsers do
  use Ecto.Migration

  def change do
    create table(:accounts_users) do
      add :email, :string
      add :name, :string
      add :password, :string, virtual: true
      add :password_hash, :string

      timestamps()
    end
  end
end
