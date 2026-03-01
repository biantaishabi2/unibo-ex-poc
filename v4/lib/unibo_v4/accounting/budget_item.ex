# Workflow: budget_item_editing — 预算项编辑流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> [*]
# ```
defmodule UniboV4.Accounting.BudgetItem do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "accounting_budget_items"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_budget_item

    mutations do
      create :create_accounting_budget_item, :create
      update :update_accounting_budget_item, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :description, :string do
      allow_nil? false
      public? true
    end
    attribute :amount, :decimal do
      allow_nil? false
      public? true
    end
    attribute :purpose, :string, public?: true
    attribute :justification, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :budget, UniboV4.Accounting.Budget do
      public? true
      allow_nil? false
    end
    belongs_to :gl_account, UniboV4.Accounting.GlAccount do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:description, :amount, :purpose, :justification]
      argument :gl_account_id, :uuid
      argument :budget_id, :uuid, allow_nil?: false
      change manage_relationship(:budget_id, :budget, type: :append, on_lookup: :relate)
      validate compare(:amount, greater_than: 0)
      # message: "预算金额必须大于零"
    end
    update :update do
      primary? true
      accept [:description, :amount, :purpose, :justification]
      # skipped: validate compare :amount (incompatible with bulk update atomic path)
      require_atomic? false
    end
  end

end
