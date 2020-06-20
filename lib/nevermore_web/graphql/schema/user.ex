defmodule NevermoreWeb.Schema.User do
  use Absinthe.Schema.Notation
  import NevermoreWeb.Errors, only: [handle_errors: 1]

  object :user do
    field :id, :id
    field :name, :string
    field :email, :string
  end

  object :session do
    field :token, :string
  end

  object :user_mutations do
    field :update_user, type: :user do
      arg(:id, non_null(:integer))
      arg(:name, :string)
      arg(:email, :string)

      resolve(handle_errors(&NevermoreWeb.Resolvers.User.update/3))
    end

    field :create_user, type: :user do
      arg(:name, non_null(:string))
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(handle_errors(&NevermoreWeb.Resolvers.User.create/3))
    end

    field :login, type: :session do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(&NevermoreWeb.Resolvers.User.login/3)
    end
  end
end
