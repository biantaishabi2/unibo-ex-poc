defmodule UniboExPoc.Ofbiz.Accounting.TaxAuthorityCategory do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_tax_authority_categories"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_tax_authority_category

    queries do
      get :get_accounting_tax_authority_category, :read
      list :list_accounting_tax_authority_categorys, :read
    end

    mutations do
      create :create_accounting_tax_authority_category, :create
      update :update_accounting_tax_authority_category, :update
      destroy :delete_accounting_tax_authority_category, :destroy
    end

  end

  attributes do
    attribute :tax_auth_geo_id, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :tax_auth_party_id, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :product_category_id, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
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
