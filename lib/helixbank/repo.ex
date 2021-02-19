defmodule Helixbank.Repo do
  use Ecto.Repo,
    otp_app: :helixbank,
    adapter: Ecto.Adapters.Postgres
end
