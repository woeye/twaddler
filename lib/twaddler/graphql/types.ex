defmodule Twaddler.GraphQL.Types do
  use Absinthe.Schema.Notation
  alias Twaddler.GraphQL.Resolvers

  scalar :time do
    description "Datetime (in ISO extended format)"
    parse &Timex.Parse.DateTime.Parser.parse(&1, "{ISO:Extended:Z}")
    serialize &Timex.Format.DateTime.Formatter.format!(&1, "{ISO:Extended:Z}")
  end

  object :user do
    field :uuid, :id
    field :username, :string
    field :email, :string
    field :roles, list_of(:string)
  end

  object :new_user do
    field :uuid, :id
  end

  object :conversation do
    field :uuid, :id
    field :topic, :string
  end

  object :message do
    field :uuid, :id
    field :conversation, :conversation do
      resolve &Resolvers.Conversations.get_conversation_by_id(&1.conversation_id,&2,&3)
    end
    field :user, :user do
      resolve &Resolvers.Users.get_user_by_id(&1.user_id, &2, &3)
    end
    field :posted, :time do
      resolve fn(message,_,_) -> {:ok, message.inserted_at} end
    end
    field :text, :string
  end
end
