# Twaddler

Twaddler is a simple chat server based on Elixir/Erlang. It is intended as learning project in order to get a better understanding about how Elixir works.

## Motivation

In one of our last projects at work we are using GraphQL as an API interface. Unfortunately we ran into performance issues which are mostly related to issue to be able do handle multiple requests to different services concurrently.

This motivated me to finally give [Elixir](https://elixir-lang.org/) a chance for it is know to be able to handle concurrent tasks very well - thanks to its erlang nature.

Elixir also features a very nice GraphQL implementation called [Absinthe](https://absinthe-graphql.org/) which supports subscriptions in a very elegant way.

In order to better understand and learn Elixir I started working on a chat server with GraphQL support.

Please note that this project is mostly intended as a learning project. But maybe other newbies like me will find the code useful :-)

## Technology Stack

The current technology stack uses:

* PostgreSQL for storing the data
* Phoenixframework as the framework
* Absinthe GraphQL as the GraphQL framework

For the future it might use:

* React as the frontend technology
* InfluxDB for storing and retrieving the messages / posts

## Future Plans

* Add functionality - ofc
* Add a simple React based UI
* Add [Guardian](https://github.com/ueberauth/guardian) for authentication
* Maybe add OAuth support
* Maybe use InfluxDB for storing the messages (instead of PostgreSQL)

## Installation

Checkout the sources into a directory:

```
git clone https://github.com/woeye/twaddler
cd twaddler
```

### PostgreSQL

Twaddler currently stores all its data in a PostgreSQL database. To get you started quickly a docker-compose file is provided:

```
docker-compose up -d postgres
docker-compose logs -f postgres
```

For stopping the PostgreSQL container use

```
docker-compose down postgres
```

### Phoenixframework / Elixir

Once the database is up and running you can initialize the database with

```
mix ecto.migrate
```

Then you need to build the JavaScript client code with

```
(cd assets && npm install && npm run build)
```

Finally you need to compile the sources and start the server:

```
mix compile
mix phx.server
```

## Accessing the GraphQL API

After the installation process you should be able to browse the GraphQL API. Open the following URL in your browser: http://localhost:4000/api/graphiql

## Thanks

I would like to thank the Elixir community for this great little language and I would also like to thank the Absinthe project for making with GraphQL fun.

## License

[Apache License 2.0](LICENSE)
