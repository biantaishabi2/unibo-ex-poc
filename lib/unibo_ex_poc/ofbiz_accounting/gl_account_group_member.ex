defmodule UniboV4.Ofbiz.Accounting.GlAccountGroupMember do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_gl_account_group_members"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_gl_account_group_member

    queries do
      get :get_accounting_gl_account_group_member, :read
      list :list_accounting_gl_account_group_members, :read
    end

    mutations do
      create :create_accounting_gl_account_group_member, :create
      update :update_accounting_gl_account_group_member, :update
      destroy :delete_accounting_gl_account_group_member, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :gl_account, UniboV4.Ofbiz.Accounting.GlAccount do
      public? true
    end
    belongs_to :gl_account_group, UniboV4.Ofbiz.Accounting.GlAccountGroup do
      public? true
    end
    belongs_to :gl_account_group_type, UniboV4.Ofbiz.Accounting.GlAccountGroupType do
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
