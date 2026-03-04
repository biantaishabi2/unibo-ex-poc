defmodule UniboV4.Accounting.Journal do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Accounting,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "accounting_journals"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :code, :string, public?: true
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read]
  end

end
