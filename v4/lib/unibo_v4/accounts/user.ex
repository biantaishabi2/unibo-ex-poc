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
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :email, :string, allow_nil?: false, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read, :update]
    create :create do
      primary? true
      accept [:name, :email]
    end
  end

  identities do
    identity :unique_email, [:email]
  end
end
