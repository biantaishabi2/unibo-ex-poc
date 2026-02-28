defmodule UniboV4.Accounting.BudgetItem do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "budget_items"
    repo UniboV4.Repo
  end

  graphql do
    type :budget_item

    mutations do
      create :create_budget_item, :create
      update :update_budget_item, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :description, :string, allow_nil?: false
    attribute :amount, :decimal, allow_nil?: false
    attribute :purpose, :string
    attribute :justification, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :budget, UniboV4.Accounting.Budget do
      allow_nil? false
    end
    belongs_to :gl_account, UniboV4.Accounting.GlAccount
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:description, :amount, :purpose, :justification]
      argument :gl_account_id, :uuid
      argument :budget_id, :uuid, allow_nil?: false
      change manage_relationship(:budget_id, :budget, type: :append, on_lookup: :relate)
    end
    update :update do
      primary? true
      accept [:description, :amount, :purpose, :justification]
    end
  end

  validations do
    validate compare(:amount, greater_than: 0)
  end

end
