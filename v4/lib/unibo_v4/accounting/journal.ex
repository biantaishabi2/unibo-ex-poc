defmodule UniboV4.Accounting.Journal do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "accounting_journals"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_journal

    queries do
      get :get_accounting_journal, :read
      list :list_accounting_journals, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :code, :string, public?: true
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
