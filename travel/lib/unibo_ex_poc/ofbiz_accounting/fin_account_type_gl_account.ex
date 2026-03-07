defmodule UniboExPoc.Ofbiz.Accounting.FinAccountTypeGlAccount do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_fin_account_type_gl_accounts"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_fin_account_type_gl_account

    queries do
      get :get_accounting_fin_account_type_gl_account, :read
      list :list_accounting_fin_account_type_gl_accounts, :read
    end

    mutations do
      create :create_accounting_fin_account_type_gl_account, :create
      update :update_accounting_fin_account_type_gl_account, :update
      destroy :delete_accounting_fin_account_type_gl_account, :destroy
    end

  end

  attributes do
    attribute :fin_account_type_id, :uuid do
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
    belongs_to :fin_account_type, UniboExPoc.Ofbiz.Accounting.FinAccountType do
      public? true
      define_attribute? false
    end
    belongs_to :gl_account, UniboExPoc.Ofbiz.Accounting.GlAccount do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
