defmodule Twaddler.GraphQL.Resolvers.Messages do
  use Timex
  import Ecto.Query
  alias Twaddler.Repo
  alias Twaddler.Db.{User, Conversation, Message}

  def get_messages(_parent, %{conversation_id: uuid, limit: limit, offset: offset}, %{context: %{current_user: current_user}}) do
    # Make sure the current user is a member of the conversation
    with {:ok, conv} <- load_conversation(uuid, current_user.uuid) do
      query = from m in Message,
        where: m.conversation_id == ^conv.id,
        limit: ^limit,
        offset: ^offset,
        order_by: [desc: m.id]

      # Prepend item to list, not append. Because: https://aneta-bielska.github.io/blog/benchmarking-elixir-lists-and-tuples-example.html
      messages = Repo.all(query) |> Enum.reverse
      {:ok, messages}
    else
      _ -> {:error, "Access denied"}
    end
  end

  def post_message(_parent, %{conversation_id: conv_uuid, text: text}, %{context: %{current_user: current_user}}) do
    with {:ok, conversation} <- load_conversation(conv_uuid, current_user.uuid) do
      changeset = Message.changeset(%Message{}, %{
        text: text,
        user_id: current_user.id,
        conversation: conversation
      })
      case Repo.insert(changeset) do
        {:ok, message} -> {:ok, message}
        {:error, changeset} -> {:error, changeset.error}
      end
    else
     _ -> {:error, "Access denied"}
    end
  end

  defp load_conversation(uuid, user_uuid) do
    ids = [user_uuid]
    query = from c in Conversation,
      where: c.uuid == ^uuid,
      where: fragment("? @> ?::varchar[]", c.participants, ^ids),
      order_by: [desc: c.id]
    case Repo.one(query) do
      nil -> {:error, "No such conversation"}
      conv -> {:ok, conv}
    end
  end
end
