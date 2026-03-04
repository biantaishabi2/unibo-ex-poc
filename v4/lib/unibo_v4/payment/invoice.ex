defmodule UniboV4.Payment.Invoice do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Payment,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "payment_invoices"
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
