defmodule Twaddler.Db.Message do
  use Ecto.Schema
  import Ecto.Changeset
  import Twaddler.Db.Common

  schema "messages" do
    field :uuid, :string
    field :text, :string
    timestamps()

    belongs_to :user, Twaddler.Db.User
    belongs_to :conversation, Twaddler.Db.Conversation
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:text])
    |> validate_required([:text])
    |> check_uuid
    |> put_assoc(:user, attrs.user)
    |> put_assoc(:conversation, attrs.conversation)
  end
end
