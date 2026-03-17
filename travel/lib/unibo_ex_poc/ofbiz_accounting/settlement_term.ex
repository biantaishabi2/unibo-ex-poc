defmodule UniboExPoc.Ofbiz.Accounting.SettlementTerm do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_settlement_terms"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_accounting_settlement_term

    queries do
      get :get_ofbiz_accounting_settlement_term, :read
      list :list_ofbiz_accounting_settlement_terms, :read
    end

    mutations do
      create :create_ofbiz_accounting_settlement_term, :create
      update :update_ofbiz_accounting_settlement_term, :update
      destroy :delete_ofbiz_accounting_settlement_term, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :settlement_term_id, :string, public?: true
    attribute :term_name, :string, public?: true
    attribute :term_value, :integer, public?: true
    attribute :uom_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
