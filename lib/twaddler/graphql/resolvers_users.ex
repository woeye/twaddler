defmodule Twaddler.GraphQL.Resolvers.Users do
  use Timex
  import Ecto.Query
  import Absinthe.Resolution.Helpers
  alias Twaddler.Repo
  alias Twaddler.Db.User

  def authenticate_user(_parent, %{:username => username, :password => password}, _ctx) do
    query = from u in User,
      where: u.username == ^username,
      select: u
    with user when user != nil <- Repo.one(query),
         {:ok, _} <- Comeonin.Argon2.check_pass(user, password)
    do
      data = %{
        id: user.id,
        uuid: user.uuid
      }
      salt = TwaddlerWeb.Endpoint.config(:token_salt)
      token = Phoenix.Token.sign(TwaddlerWeb.Endpoint, salt, data)
      {:ok, token}
    else
      _ -> {:error, "Invalid username/password combination"}
    end
  end

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
