defmodule Twaddler.GraphQL.Resolvers.Messages do
  use Timex
  import Ecto.Query
  alias Twaddler.Repo
  alias Twaddler.Db.{User, Conversation, Message}

  def get_messages(_parent, %{:conversation_id => uuid, :limit => limit, :offset => offset}, _resolution) do
    query = from m in Message,
      join: c in Conversation,
      where: m.conversation_id == c.id,
      where: c.uuid == ^uuid,
      limit: ^limit,
      offset: ^offset,
      order_by: [desc: m.id],
      select: m

    # Prepend item to list, not append. Because: https://aneta-bielska.github.io/blog/benchmarking-elixir-lists-and-tuples-example.html
    messages = Repo.all(query) |> Enum.reverse
    {:ok, messages}
  end

  def post_message(_parent, %{:conversation_id => conv_uuid, :user_id => user_uuid, :text => text}, _resolution) do
    with {:ok, conversation} <- load_by_uuid(Conversation, "conversation", conv_uuid),
      {:ok, user} <- load_by_uuid(User, "user", user_uuid)
    do
      changeset = Message.changeset(%Message{}, %{
        text: text,
        user: user,
        conversation: conversation
      })
      case Repo.insert(changeset) do
        {:ok, message} -> {:ok, message}
        {:error, changeset} -> {:error, changeset.error}
      end
    else
      err -> err
    end
  end

  defp load_by_uuid(entity, name, uuid) do
    entity
    |> Repo.get_by(uuid: uuid)
    |> case do
      nil -> {:error, "Invalid UUID for #{name}: #{uuid}"}
      conv -> {:ok, conv}
    end
  end
end
