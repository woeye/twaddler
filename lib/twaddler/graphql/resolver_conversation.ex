defmodule Twaddler.GraphQL.Resolvers.Conversations do
  import Absinthe.Resolution.Helpers
  import Ecto.Query
  alias Twaddler.Repo
  alias Twaddler.Db.{Conversation}

  def get_conversation_by_id(conversation_id, _args, %{context: %{loader: loader}}) do
    Dataloader.load(loader, :ecto_source, Conversation, conversation_id)
    |> on_load(fn loader ->
      conversation = Dataloader.get(loader, :ecto_source, Conversation, conversation_id)
      {:ok, conversation}
    end)
  end

  def get_conversations(_parent, %{:user_id => user_id}, _) do
    ids = [user_id]
    query = from c in Conversation,
      where: fragment("? @> ?::varchar[]", c.participants, ^ids),
      order_by: [desc: c.id],
      select: c

    # Prepend item to list, not append. Because: https://aneta-bielska.github.io/blog/benchmarking-elixir-lists-and-tuples-example.html
    conversations = Repo.all(query)
    {:ok, conversations}
  end

  def start_conversation(_parent, %{:topic => topic, :participants => participants}, _res) do
    IO.puts "start_conversation with topic"

    changeset = Conversation.changeset(%Conversation{}, %{
      topic: topic,
      participants: participants
    })
    case Repo.insert(changeset) do
      {:ok, conversation} -> {:ok, conversation}
      {:error, changeset} -> {:error, Enum.reduce(changeset.errors, [], &handle_error/2)}
    end
  end

  def start_conversation(parent, %{:participants => participants}, res) do
    IO.puts "start_conversation without topic"
    start_conversation(parent, %{:participants => participants, :topic => ""}, res)
  end

  defp handle_error({_key, {reason, _extra}}, acc) do
    [reason | acc]
  end
end
