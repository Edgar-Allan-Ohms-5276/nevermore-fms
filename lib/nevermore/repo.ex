defmodule Nevermore.Repo do
  use Ecto.Repo,
    otp_app: :nevermore,
    adapter: Ecto.Adapters.Postgres

  def data() do
    Dataloader.Ecto.new(Nevermore.Repo, query: &query/2)
  end

  def query(queryable, _params) do
    queryable
  end
end
