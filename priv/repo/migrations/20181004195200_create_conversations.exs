defmodule Twaddler.Repo.Migrations.CreateConversations do
  use Ecto.Migration

  def change do
    create table(:conversations) do
      add :uuid, :string
      add :topic, :string
      add :participants, {:array, :string}
      timestamps()
    end

    create unique_index(:conversations, [:uuid])
    create index(:conversations, [:participants], using: "GIN")
  end
end
