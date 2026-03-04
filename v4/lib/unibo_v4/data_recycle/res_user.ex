defmodule UniboV4.DataRecycle.ResUser do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.DataRecycle,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "data_recycle_res_users"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read]
  end

end
