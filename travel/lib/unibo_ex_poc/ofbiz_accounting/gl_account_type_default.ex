defmodule UniboExPoc.Ofbiz.Accounting.GlAccountTypeDefault do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_gl_account_type_defaults"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_gl_account_type_default

    queries do
      get :get_accounting_gl_account_type_default, :read
      list :list_accounting_gl_account_type_defaults, :read
    end

    mutations do
      create :create_accounting_gl_account_type_default, :create
      update :update_accounting_gl_account_type_default, :update
      destroy :delete_accounting_gl_account_type_default, :destroy
    end

  end

  attributes do
    attribute :organization_party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :gl_account_type, UniboExPoc.Ofbiz.Accounting.GlAccountType do
      public? true
    end
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
