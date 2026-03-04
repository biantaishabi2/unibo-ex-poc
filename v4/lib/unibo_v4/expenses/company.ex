defmodule UniboV4.Expenses.Company do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Expenses,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "expenses_companies"
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
