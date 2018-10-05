defmodule TwaddlerWeb.PageController do
  use TwaddlerWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
