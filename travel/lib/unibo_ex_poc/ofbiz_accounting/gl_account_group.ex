defmodule UniboExPoc.Ofbiz.Accounting.GlAccountGroup do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_gl_account_groups"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_gl_account_group

    queries do
      get :get_accounting_gl_account_group, :read
      list :list_accounting_gl_account_groups, :read
    end

    mutations do
      create :create_accounting_gl_account_group, :create
      update :update_accounting_gl_account_group, :update
      destroy :delete_accounting_gl_account_group, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :gl_account_group_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :gl_account_group_type, UniboExPoc.Ofbiz.Accounting.GlAccountGroupType do
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
