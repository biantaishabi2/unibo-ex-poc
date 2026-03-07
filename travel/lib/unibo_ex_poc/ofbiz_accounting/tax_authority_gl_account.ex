defmodule UniboExPoc.Ofbiz.Accounting.TaxAuthorityGlAccount do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_tax_authority_gl_accounts"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_tax_authority_gl_account

    queries do
      get :get_accounting_tax_authority_gl_account, :read
      list :list_accounting_tax_authority_gl_accounts, :read
    end

    mutations do
      create :create_accounting_tax_authority_gl_account, :create
      update :update_accounting_tax_authority_gl_account, :update
      destroy :delete_accounting_tax_authority_gl_account, :destroy
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
    attribute :organization_party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :gl_account, UniboExPoc.Ofbiz.Accounting.GlAccount do
      public? true
    end
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
