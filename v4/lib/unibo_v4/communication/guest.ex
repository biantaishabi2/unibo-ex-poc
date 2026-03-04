defmodule UniboV4.Communication.Guest do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Communication,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "communication_guests"
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
