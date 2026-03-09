defmodule UniboExPoc.Ofbiz.Accounting.PartyTaxAuthInfo do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_party_tax_auth_infos"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_party_tax_auth_info

    queries do
      get :get_accounting_party_tax_auth_info, :read
      list :list_accounting_party_tax_auth_infos, :read
    end

    mutations do
      create :create_accounting_party_tax_auth_info, :create
      update :update_accounting_party_tax_auth_info, :update
      destroy :delete_accounting_party_tax_auth_info, :destroy
    end

  end

  attributes do
    attribute :party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
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
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :party_tax_id, :string, public?: true
    attribute :is_exempt, :boolean, public?: true
    attribute :is_nexus, :boolean, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
