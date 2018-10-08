defmodule TwaddlerWeb.Router do
  use TwaddlerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug TwaddlerWeb.Context
  end

  pipeline :graphql do
    plug TwaddlerWeb.Context
  end

  scope "/", TwaddlerWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api" do
    pipe_through :graphql

    forward "/graphiql", Absinthe.Plug.GraphiQL,
       schema: Twaddler.GraphQL.Schema

    forward "/", Absinthe.Plug,
       schema: Twaddler.GraphQL.Schema
  end

end
