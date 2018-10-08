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

  def get_conversations(_parent, _args, %{context: %{current_user: current_user}}) do
    ids = [current_user.uuid]
    query = from c in Conversation,
      where: fragment("? @> ?::varchar[]", c.participants, ^ids),
      order_by: [desc: c.id]

    # Prepend item to list, not append. Because: https://aneta-bielska.github.io/blog/benchmarking-elixir-lists-and-tuples-example.html
    conversations = Repo.all(query)
    {:ok, conversations}
  end

  def get_conversations(_parent, _args, _), do: {:error, "Unauthorized"}

  def start_conversation(_parent, %{topic: topic, participants: participants}, %{context: %{current_user: current_user}}) do
    participants = [current_user.uuid | participants] # Add in the UUID of the current user
    changeset = Conversation.changeset(%Conversation{}, %{
      topic: topic,
      participants: participants
    })
    case Repo.insert(changeset) do
      {:ok, conversation} -> {:ok, conversation}
      {:error, changeset} -> {:error, Enum.reduce(changeset.errors, [], &handle_error/2)}
    end
  end

  def start_conversation(parent, %{participants: participants}, ctx) do
    IO.puts "start_conversation without topic"
    start_conversation(parent, %{participants: participants, topic: ""}, ctx)
  end

  def start_conversation(_parent, _, _), do: {:error, "Unauthorized"}

  defp handle_error({_key, {reason, _extra}}, acc) do
    [reason | acc]
  end
end
