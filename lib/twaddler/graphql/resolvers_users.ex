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
    loader
    |> Dataloader.load(:twaddler, User, user_id)
    |> on_load(fn loader ->
      user = Dataloader.get(loader, :twaddler, User, user_id)
      {:ok, user}
    end)
  end
end
