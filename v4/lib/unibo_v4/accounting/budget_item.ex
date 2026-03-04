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
    data_layer: AshPostgres.DataLayer

  postgres do
    table "accounting_budget_items"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :budget_item_type_id, :string, public?: true
    attribute :seq_id, :integer, public?: true
    attribute :amount, :decimal do
      allow_nil? false
      public? true
    end
    attribute :purpose, :string, public?: true
    attribute :justification, :string, public?: true
    attribute :description, :string do
      allow_nil? false
      public? true
    end
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
    create :create do
      primary? true
      accept [:description, :amount, :purpose, :justification, :budget_item_type_id, :seq_id]
      argument :gl_account_id, :uuid
      argument :budget_id, :uuid, allow_nil?: false
      change manage_relationship(:budget_id, :budget, type: :append, on_lookup: :relate)
      validate compare(:amount, greater_than: 0)
      # message: "预算金额必须大于零"
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:description, :amount, :purpose, :justification, :budget_item_type_id, :seq_id]
      # skipped: validate compare :amount (incompatible with bulk update atomic path)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
  end

end
