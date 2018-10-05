defmodule Twaddler.Db.Conversation do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  import Twaddler.Db.Common
  alias Twaddler.Repo
  alias Twaddler.Db.User

  schema "conversations" do
    field :uuid, :string
    field :topic, :string
    field :participants, {:array, :string}
    timestamps()

    has_many :messages, Twaddler.Db.Message
    # many_to_many :users, Twaddler.Db.User, join_through: "users_conversations"
  end

  @doc false
  def changeset(conversation, attrs) do
    conversation
      |> cast(attrs, [:topic, :participants])
      |> validate_required([:participants])
      |> unique_participants
      |> check_size
      |> check_existing
      |> check_valid_participants
      |> check_uuid()
    end

  defp unique_participants(changeset) do
    update_change(changeset, :participants, &Enum.uniq/1)
  end

  defp check_size(changeset) do
    ids = get_change(changeset, :participants)
    size = length(ids)
    cond do
      size < 2 -> add_error(changeset, :participants, "Please provide at least two unique user IDs")
      size > 2 -> add_error(changeset, :participants, "Group chat isn't supported yet")
      true -> changeset
    end
  end

  defp check_existing(changeset) do
    ids = get_change(changeset, :participants)

    query =
      from c in __MODULE__,
      where: fragment("? <@ ?::varchar[]", c.participants, ^ids),
      where: fragment("? @> ?::varchar[]", c.participants, ^ids),
      select: c,
      limit: 1
    case Repo.one(query) do
      nil -> changeset
      existing_conv -> add_error(changeset, :participants, "Conversation for the given participants already exist", existing: existing_conv)
    end
  end

  defp check_valid_participants(changeset) do
    ids = get_change(changeset, :participants)
    db_ids = Repo.all(from u in User, where: u.uuid in ^ids, select: u.uuid)

    ids
    |> Enum.filter(&!Enum.member?(db_ids, &1))
    |> Enum.join(", ")
    |> case do
      "" -> changeset
      unknown_ids -> add_error(changeset, :participants, "Unknown UUIDs: #{unknown_ids}")
    end
  end
end
