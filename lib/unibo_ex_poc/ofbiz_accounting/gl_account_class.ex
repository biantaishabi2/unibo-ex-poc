defmodule UniboV4.Ofbiz.Accounting.GlAccountClass do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_gl_account_classes"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_gl_account_class

    queries do
      get :get_accounting_gl_account_class, :read
      list :list_accounting_gl_account_classs, :read
    end

    mutations do
      create :create_accounting_gl_account_class, :create
      update :update_accounting_gl_account_class, :update
      destroy :delete_accounting_gl_account_class, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :gl_account_class_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :is_asset_class, :boolean, public?: true
    attribute :sequence_num, :integer, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_gl_account_class, UniboV4.Ofbiz.Accounting.GlAccountClass do
      public? true
      source_attribute :parent_class_id
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
