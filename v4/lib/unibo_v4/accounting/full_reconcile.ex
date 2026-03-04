# Workflow: full_reconcile_lifecycle — 完全核销生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Accounting.FullReconcile do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Accounting,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "accounting_full_reconciles"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :partial_reconciles, UniboV4.Accounting.PartialReconcile do
      public? true
    end
    has_many :reconciled_lines, UniboV4.Accounting.JournalEntryLine do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept []
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 change effect custom
    end
  end

end
