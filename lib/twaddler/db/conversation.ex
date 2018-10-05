defmodule Twaddler.Db.Conversation do
  use Ecto.Schema
  import Ecto.Changeset
  import Twaddler.Db.Common

  schema "conversations" do
    field :uuid, :string
    field :topic, :string
    field :participants, {:array, :string}
    timestamps()

    has_many :messages, Twaddler.Db.Message
  end

  @doc false
  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [:topic, :participants])
    |> validate_required([:participants])
    |> check_uuid()
  end
end
