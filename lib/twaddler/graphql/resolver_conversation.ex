defmodule Twaddler.GraphQL.Resolvers.Conversations do
  import Ecto.Query
  import Absinthe.Resolution.Helpers
  alias Twaddler.Repo
  alias Twaddler.Db.{User, Conversation}

  def get_conversation_by_id(conversation_id, _args, %{context: %{loader: loader}}) do
    loader
    |> Dataloader.load(:twaddler, Conversation, conversation_id)
    |> on_load(fn loader ->
      conversation = Dataloader.get(loader, :twaddler, Conversation, conversation_id)
      {:ok, conversation}
    end)
  end

  def start_conversation(_parent, %{:topic => topic, :participants => participants}, _res) do
    IO.puts "start_conversation with topic"

    participants
    |> Enum.uniq
    |> check_existing_conversation
    |> verify_participant_ids
    |> case do
      {:error, reason} -> {:error, reason}
      {:reuse, uuid} -> {:ok, %{:uuid => uuid}}
      {:ok, ids} ->
        Conversation.changeset(%Conversation{}, %{
          :topic => topic,
          :participants => ids
        })
        |> Repo.insert
    end
  end

  def start_conversation(parent, %{:participants => participants}, res) do
    IO.puts "start_conversation without topic"
    start_conversation(parent, %{:participants => participants, :topic => ""}, res)
  end

  defp check_existing_conversation(ids) do
    query =
      from c in Conversation,
      where: fragment("? <@ ?::varchar[]", c.participants, ^ids),
      select: c.uuid,
      limit: 1
    case Repo.one(query) do
      nil -> ids
      uuid -> {:reuse, uuid}
    end
  end

  defp verify_participant_ids({:reuse, uuid}) do
    {:reuse, uuid}
  end

  defp verify_participant_ids(ids) when length(ids) < 2 do
    {:error, "Not enough unique user UUIDs were given"}
  end

  defp verify_participant_ids(ids) when length(ids) > 2 do
    {:error, "Group chat is not supported yet"}
  end

  defp verify_participant_ids(ids) do
    db_ids = Repo.all(from u in User, where: u.uuid in ^ids, select: u.uuid)

    ids
    |> Enum.filter(&!Enum.member?(db_ids, &1))
    |> Enum.join(", ")
    |> case do
      "" -> {:ok, ids}
      unknown_ids -> {:error, "Unknown UUIDs: #{unknown_ids}"}
    end
  end
end
