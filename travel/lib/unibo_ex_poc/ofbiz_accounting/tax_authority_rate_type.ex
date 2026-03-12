defmodule UniboExPoc.Ofbiz.Accounting.TaxAuthorityRateType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_tax_authority_rate_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_accounting_tax_authority_rate_type

    queries do
      get :get_ofbiz_accounting_tax_authority_rate_type, :read
      list :list_ofbiz_accounting_tax_authority_rate_types, :read
    end

    mutations do
      create :create_ofbiz_accounting_tax_authority_rate_type, :create
      update :update_ofbiz_accounting_tax_authority_rate_type, :update
      destroy :delete_ofbiz_accounting_tax_authority_rate_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :tax_authority_rate_type_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
