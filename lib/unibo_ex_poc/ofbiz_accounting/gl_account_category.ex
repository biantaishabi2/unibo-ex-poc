defmodule UniboExPoc.Ofbiz.Accounting.GlAccountCategory do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_gl_account_categories"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_gl_account_category

    queries do
      get :get_accounting_gl_account_category, :read
      list :list_accounting_gl_account_categorys, :read
    end

    mutations do
      create :create_accounting_gl_account_category, :create
      update :update_accounting_gl_account_category, :update
      destroy :delete_accounting_gl_account_category, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :gl_account_category_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :gl_account_category_type, UniboExPoc.Ofbiz.Accounting.GlAccountCategoryType do
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
