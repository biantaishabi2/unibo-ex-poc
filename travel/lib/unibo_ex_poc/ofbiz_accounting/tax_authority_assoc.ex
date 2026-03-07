defmodule UniboExPoc.Ofbiz.Accounting.TaxAuthorityAssoc do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_tax_authority_assocs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_tax_authority_assoc

    queries do
      get :get_accounting_tax_authority_assoc, :read
      list :list_accounting_tax_authority_assocs, :read
    end

    mutations do
      create :create_accounting_tax_authority_assoc, :create
      update :update_accounting_tax_authority_assoc, :update
      destroy :delete_accounting_tax_authority_assoc, :destroy
    end

  end

  attributes do
    attribute :tax_auth_geo_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :tax_auth_party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :to_tax_auth_geo_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :to_tax_auth_party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :tax_authority_assoc_type, UniboExPoc.Ofbiz.Accounting.TaxAuthorityAssocType do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
