defmodule UniboExPoc.Ofbiz.Accounting.GlAccountGroupMember do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_gl_account_group_members"
    repo UniboExPoc.Repo
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
    attribute :gl_account_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :gl_account_group_type_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :gl_account, UniboExPoc.Ofbiz.Accounting.GlAccount do
      public? true
      define_attribute? false
    end
    belongs_to :gl_account_group, UniboExPoc.Ofbiz.Accounting.GlAccountGroup do
      public? true
    end
    belongs_to :gl_account_group_type, UniboExPoc.Ofbiz.Accounting.GlAccountGroupType do
      public? true
      define_attribute? false
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
