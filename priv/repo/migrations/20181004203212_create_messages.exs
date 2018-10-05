defmodule Twaddler.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :uuid, :string
      add :text, :text
      add :user_id, references(:users)
      add :conversation_id, references(:conversations)
      timestamps()
    end

    create index(:messages, [:conversation_id])
    create unique_index(:messages, [:uuid])
  end
end
