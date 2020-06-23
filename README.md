# Nevermore FMS Backend

This is the backend component to the Nevermore FMS. It is written in Elixir and uses [Phoenix](https://www.phoenixframework.org/) with [Absinthe](https://github.com/absinthe-graphql/absinthe) to create a GraphQL API that can be used by a frontend to control the FMS.

Features:

 * Full implementation of the FMS protocol allows for driverstation connections.
 * Team import from [The Blue Alliance](https://www.thebluealliance.com/).
 * GraphQL API for easy frontend creation.

To start the server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000/api/playground`](http://localhost:4000/api/playground) from your browser to use the [GraphQL Playground](https://github.com/prisma-labs/graphql-playground)

## License
This project is licensed under the GNU GPL v3 license. That means if you make any modifications to the source code then your new project must be under the same Open Source license. If you need another license for whatever reason, contact me at [mcmackety@rodiconmc.com](mailto:mcmackety@rodiconmc.com?subject=%5BNevermore%20Backend%5D%20License%20Request&body=%0D%0A%0D%0A).
