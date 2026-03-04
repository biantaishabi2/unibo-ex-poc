defmodule UniboV4.Helpdesk.User do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "helpdesk_users"
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
