defmodule Twaddler.GraphQL.Schema do
  use Absinthe.Schema

  import_types Twaddler.GraphQL.Types
  alias Twaddler.GraphQL.Resolvers

  def context(ctx) do
    source = Dataloader.Ecto.new(Twaddler.Repo)
    loader = Dataloader.new
      |> Dataloader.add_source(:twaddler, source)

    Map.put(ctx, :loader, loader)
  end

  query do
    field :get_users, list_of(:user) do
      resolve &Resolvers.Users.get_users/3
    end

    field :get_messages, list_of(:message) do
      arg :conversation_id, non_null(:string)
      arg :limit, non_null(:integer)
      arg :offset, non_null(:integer)
      resolve &Resolvers.Messages.get_messages/3
    end
  end

  mutation do
    field :start_conversation, :conversation do
      arg :topic, :string
      arg :participants, non_null(list_of(:id))
      resolve &Resolvers.Conversations.start_conversation/3
    end

    field :post_message, :message do
      arg :conversation_id, non_null(:id)
      arg :user_id, non_null(:id)
      arg :text, non_null(:string)
      resolve &Resolvers.Messages.post_message/3
    end

    field :create_user, :new_user do
      arg :username, non_null(:string)
      arg :email, non_null(:string)
      arg :password, non_null(:string)
    end
  end

  subscription do
    field :message_posted, :message do
      arg :conversation_id, non_null(:id)

      config fn args, _ ->
        IO.puts "Registering subscription for channel #{args.conversation_id}"
        {:ok, topic: args.conversation_id}
      end

      trigger :post_message, topic: fn message ->
        IO.inspect(message)
        IO.inspect(message.conversation.uuid)
        message.conversation.uuid
      end

      resolve fn message, _, _ ->
        IO.inspect(message)
        {:ok, message}
      end
    end
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
