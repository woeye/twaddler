defmodule TwaddlerWeb.Context do
  @behaviour Plug

  import Plug.Conn
  # import Ecto.Query

  # alias Twaddler.Repo
  # alias Twaddler.Db.User

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  defp build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, current_user} <- fetch_user(token)
    do
      %{current_user: current_user}
    else
      _ -> %{}
    end
  end

  defp fetch_user(token) do
    salt = TwaddlerWeb.Endpoint.config(:token_salt)
    Phoenix.Token.verify(TwaddlerWeb.Endpoint, salt, token)
  end
end
