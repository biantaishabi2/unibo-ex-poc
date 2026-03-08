# Workflow: reconciliation_flow — 核销流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Accounting.PartialReconcile do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "部分核销记录，连接借方行与贷方行 [R-REC-001][R-REC-002]"
  end

  postgres do
    table "accounting_partial_reconciles"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_partial_reconcile

    queries do
      get :get_accounting_partial_reconcile, :read
      list :list_accounting_partial_reconciles, :read
    end

    mutations do
      create :create_accounting_partial_reconcile, :create
      destroy :delete_accounting_partial_reconcile, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :amount, :decimal do
      allow_nil? false
      public? true
      description "核销金额（本位币）"
    end
    attribute :debit_amount_currency, :decimal do
      public? true
      description "借方外币核销金额"
    end
    attribute :credit_amount_currency, :decimal do
      public? true
      description "贷方外币核销金额"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :debit_line, UniboV4.Accounting.JournalEntryLine do
      public? true
      allow_nil? false
    end
    belongs_to :credit_line, UniboV4.Accounting.JournalEntryLine do
      public? true
      allow_nil? false
    end
    belongs_to :full_reconcile, UniboV4.Accounting.FullReconcile do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy, :update]
    create :create do
      primary? true
      accept [:amount, :debit_amount_currency, :credit_amount_currency]
      argument :debit_line_id, :uuid, allow_nil?: false
      argument :credit_line_id, :uuid, allow_nil?: false
      change manage_relationship(:debit_line_id, :debit_line, type: :append, on_lookup: :relate)
      change manage_relationship(:credit_line_id, :credit_line, type: :append, on_lookup: :relate)
      validate compare(:amount, greater_than: 0)
      # message: "核销金额必须大于零"
      # validation: same_account_same_partner
      change UniboV4.Accounting.Changes.PartialReconcile.CreateCall1
      change UniboV4.Accounting.Changes.PartialReconcile.CreateCall2
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
