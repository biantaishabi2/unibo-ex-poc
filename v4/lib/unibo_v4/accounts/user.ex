defmodule UniboV4.Accounts.User do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Accounts,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "users"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false
    attribute :email, :string, allow_nil?: false
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read, :create, :update]
  end

  identities do
    identity :unique_email, [:email]
  end
end
