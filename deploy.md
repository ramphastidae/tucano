## How to deploy?

Here you can check an example on how to deploy this platform. However, you can find more info here:

* [Phoenix - Introduction to Deployment](https://hexdocs.pm/phoenix/deployment.html)
* [Create React App - Deployment](https://create-react-app.dev/docs/deployment/)

### Backend

Requirements:
* PostgreSQL 11.3
* Erlang 21.3
* Elixir 1.8

Access `config/` folder.

```
cp prod.secret.sample.exs prod.secret.exs
# configure secrets
vi prod.secret.exs
# configure url
vi prod.exs
```

You may also want to edit `priv/repo/seeds.exs` for **Admin** credentials.

```
mix deps.get --only prod
MIX_ENV=prod mix compile
MIX_ENV=prod mix ecto.setup
MIX_ENV=prod PORT=4001 elixir --detached -S mix do compile, phx.server
```

### Frontend

Requirements:
* nodejs 11.10.0
* yarn 
* serve

```
yarn install

cp .env.sample .env
# edit API url
vi .env
source .env

# compile
yarn build
serve -s build -l PORT
```