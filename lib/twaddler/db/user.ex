defmodule Twaddler.Db.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Twaddler.Db.Common

  schema "users" do
    field :uuid, :string
    field :username, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :email, :string
    timestamps()

    many_to_many :roles, Twaddler.Db.Role, join_through: "users_roles"
    # many_to_many :conversations, Twaddler.Db.Conversation, join_through: "users_conversations"
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password])
    |> validate_required([:username, :email, :password])
    |> check_uuid
    |> hash_password
  end

  defp hash_password(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      password -> put_change(changeset, :password_hash, Comeonin.Argon2.hashpwsalt(password))
    end
  end
end
