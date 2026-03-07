defmodule UniboExPoc.Ofbiz.Accounting.GlReconciliationEntry do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_gl_reconciliation_entries"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_gl_reconciliation_entry

    queries do
      get :get_accounting_gl_reconciliation_entry, :read
      list :list_accounting_gl_reconciliation_entrys, :read
    end

    mutations do
      create :create_accounting_gl_reconciliation_entry, :create
      update :update_accounting_gl_reconciliation_entry, :update
      destroy :delete_accounting_gl_reconciliation_entry, :destroy
    end

  end

  attributes do
    attribute :acctg_trans_entry_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :reconciled_amount, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :gl_reconciliation, UniboExPoc.Ofbiz.Accounting.GlReconciliation do
      public? true
    end
    belongs_to :acctg_trans, UniboExPoc.Ofbiz.Accounting.AcctgTrans do
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
