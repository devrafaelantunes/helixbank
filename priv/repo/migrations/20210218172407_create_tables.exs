defmodule Helixbank.Repo.Migrations.CreateTables do
  use Ecto.Migration

  def change do
    create table(:account, primary_key: false) do
      add :account_id, :serial, primary_key: true
      add :name, :string, null: false
      add :amount, :float
      add :account_number, :integer, null: false
      add :agency_id, :integer, null: false
      add :document, :string, null: false
      add :password_hash, :string

      timestamps()
    end

    create unique_index(:account, [:document])
  end
end
