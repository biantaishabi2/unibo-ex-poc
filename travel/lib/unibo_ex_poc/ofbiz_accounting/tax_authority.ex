defmodule UniboExPoc.Ofbiz.Accounting.TaxAuthority do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_tax_authorities"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_tax_authority

    queries do
      get :get_accounting_tax_authority, :read
      list :list_accounting_tax_authoritys, :read
    end

    mutations do
      create :create_accounting_tax_authority, :create
      update :update_accounting_tax_authority, :update
      destroy :delete_accounting_tax_authority, :destroy
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
    attribute :require_tax_id_for_exemption, :boolean, public?: true
    attribute :tax_id_format_pattern, :string, public?: true
    attribute :include_tax_in_price, :boolean, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
