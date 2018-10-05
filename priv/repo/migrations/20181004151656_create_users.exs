defmodule Twaddler.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :uuid, :string
      add :username, :string
      add :password_hash, :string
      add :email, :string
      timestamps()
    end

    create index(:users, [:username])
    create index(:users, [:email])
    create unique_index(:users, [:uuid])
  end
end
