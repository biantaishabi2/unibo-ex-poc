defmodule UniboV4.Ofbiz.Accounting.GlReconciliation do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_gl_reconciliations"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_gl_reconciliation

    queries do
      get :get_accounting_gl_reconciliation, :read
      list :list_accounting_gl_reconciliations, :read
    end

    mutations do
      create :create_accounting_gl_reconciliation, :create
      update :update_accounting_gl_reconciliation, :update
      destroy :delete_accounting_gl_reconciliation, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :gl_reconciliation_id, :string, public?: true
    attribute :gl_reconciliation_name, :string, public?: true
    attribute :description, :string, public?: true
    attribute :created_date, :utc_datetime, public?: true
    attribute :created_by_user_login, :string, public?: true
    attribute :last_modified_date, :utc_datetime, public?: true
    attribute :last_modified_by_user_login, :string, public?: true
    attribute :status_id, :string, public?: true
    attribute :organization_party_id, :string, public?: true
    attribute :reconciled_balance, :decimal, public?: true
    attribute :opening_balance, :decimal, public?: true
    attribute :reconciled_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :gl_account, UniboV4.Ofbiz.Accounting.GlAccount do
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
