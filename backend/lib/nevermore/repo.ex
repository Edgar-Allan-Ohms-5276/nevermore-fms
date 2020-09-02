defmodule Nevermore.Repo do
  use Ecto.Repo,
    otp_app: :nevermore,
    adapter: Ecto.Adapters.Postgres
end
