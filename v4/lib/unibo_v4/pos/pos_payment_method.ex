defmodule UniboV4.POS.PosPaymentMethod do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.POS,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "pos_payment_methods"
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
