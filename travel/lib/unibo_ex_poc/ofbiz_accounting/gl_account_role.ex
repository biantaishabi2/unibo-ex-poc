defmodule UniboExPoc.Ofbiz.Accounting.GlAccountRole do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_gl_account_roles"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_gl_account_role

    queries do
      get :get_accounting_gl_account_role, :read
      list :list_accounting_gl_account_roles, :read
    end

    mutations do
      create :create_accounting_gl_account_role, :create
      update :update_accounting_gl_account_role, :update
      destroy :delete_accounting_gl_account_role, :destroy
    end

  end

  attributes do
    attribute :party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :role_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
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
