defmodule Twaddler.GraphQL.Resolvers.Users do
  use Timex
  import Absinthe.Resolution.Helpers
  alias Twaddler.Repo
  alias Twaddler.Db.User

  def get_users(_parent, _args, _res) do
    users = User |> Repo.all
    {:ok, users}
  end

  def get_user_by_id(user_id, _args, %{context: %{loader: loader}}) do
    Dataloader.load(loader, :ecto_source, User, user_id)
    |> on_load(fn loader ->
      user = Dataloader.get(loader, :ecto_source, User, user_id)
      {:ok, user}
    end)
  end

  def get_users_by_uuids(user_uuids, _args, %{context: %{loader: loader}}) do
    Dataloader.load_many(loader, :uuid_source, User, user_uuids)
    |> on_load(fn loader ->
      users = Dataloader.get_many(loader, :uuid_source, User, user_uuids)
      {:ok, users}
    end)
  end
end
