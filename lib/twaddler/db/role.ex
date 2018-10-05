defmodule Twaddler.Db.Role do
  use Ecto.Schema
  import Ecto.Changeset
  import Twaddler.Db.Common

  schema "roles" do
    field :uuid, :string
    field :name, :string
    timestamps()

    many_to_many :users, Twaddler.Db.User, join_through: "users_roles"
  end

  def changeset(role, attrs) do
    role
    |> cast(attrs, [:uuid, :name])
    |> validate_required([:name])
    |> check_uuid
  end
end
