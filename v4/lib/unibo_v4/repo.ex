defmodule UniboV4.Repo do
  use AshPostgres.Repo,
    otp_app: :unibo_v4

  def installed_extensions do
    ["ash-functions", "uuid-ossp", "citext"]
  end

  def min_pg_version do
    %Version{major: 16, minor: 0, patch: 0}
  end
end
