defmodule Mix.Tasks.Twaddler.User.Add do
  use Mix.Task
  # import Ecto.Query
  alias Twaddler.Repo
  alias Twaddler.Db.User

  @shortdoc "Adds a user to the system"

  @moduledoc """
  Adds a new user to the system.

  ## Examples
      mix twaddler.user.add john john@doe.com lazypw
  """
  def run(args) do
    Mix.Task.run "app.start", []

    args
    |> List.to_tuple()
    |> create_user
  end

  defp create_user({username, email, password}) do
    Mix.shell.info "Creating user ..."

    user = User.changeset(%User{}, %{
      :username => username,
      :email => email,
      :password => password
    })
    case Repo.insert(user) do
      {:ok, user} -> Mix.shell.info "Created user with uuid: #{user.uuid}"
    end
  end

  defp create_user(_) do
    Mix.raise "You must provide three parameters: <username> <email> <password>"
  end

  # We can define other functions as needed here.
end
