defmodule UniboExPoc.Ofbiz.Accounting.GlAccount do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_gl_accounts"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_gl_account

    queries do
      get :get_accounting_gl_account, :read
      list :list_accounting_gl_accounts, :read
    end

    mutations do
      create :create_accounting_gl_account, :create
      update :update_accounting_gl_account, :update
      destroy :delete_accounting_gl_account, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :gl_account_id, :string, public?: true
    attribute :account_code, :string, public?: true
    attribute :account_name, :string, public?: true
    attribute :description, :string, public?: true
    attribute :product_id, :string, public?: true
    attribute :external_id, :string do
      public? true
      description "账户在外部系统中的id，该系统是账户导入/导出的地方"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :gl_account_type, UniboExPoc.Ofbiz.Accounting.GlAccountType do
      public? true
    end
    belongs_to :gl_account_class, UniboExPoc.Ofbiz.Accounting.GlAccountClass do
      public? true
    end
    belongs_to :gl_resource_type, UniboExPoc.Ofbiz.Accounting.GlResourceType do
      public? true
    end
    belongs_to :gl_xbrl_class, UniboExPoc.Ofbiz.Accounting.GlXbrlClass do
      public? true
    end
    belongs_to :parent_gl_account, UniboExPoc.Ofbiz.Accounting.GlAccount do
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
