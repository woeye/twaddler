defmodule Twaddler.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :uuid, :string
      add :name, :string
      timestamps()
    end

    create unique_index(:roles, [:uuid])
  end
end
