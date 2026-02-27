defmodule UniboExPoc.Repo do
  use Ecto.Repo,
    otp_app: :unibo_ex_poc,
    adapter: Ecto.Adapters.Postgres
end
