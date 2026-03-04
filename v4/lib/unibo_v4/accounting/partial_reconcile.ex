# Workflow: reconciliation_flow — 核销流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Accounting.PartialReconcile do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Accounting,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "accounting_partial_reconciles"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :amount, :decimal do
      allow_nil? false
      public? true
    end
    attribute :debit_amount_currency, :decimal, public?: true
    attribute :credit_amount_currency, :decimal, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
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
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:amount, :debit_amount_currency, :credit_amount_currency]
      argument :debit_line_id, :uuid, allow_nil?: false
      argument :credit_line_id, :uuid, allow_nil?: false
      change manage_relationship(:debit_line_id, :debit_line, type: :append, on_lookup: :relate)
      change manage_relationship(:credit_line_id, :credit_line, type: :append, on_lookup: :relate)
      validate compare(:amount, greater_than: 0)
      # message: "核销金额必须大于零"
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 change effect custom
      # TODO: 不支持的 change effect custom
    end
  end

end
