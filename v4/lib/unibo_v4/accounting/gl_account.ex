# Workflow: gl_account_lifecycle — 科目管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> deactivate
#   update --> update
#   update --> deactivate
#   deactivate --> [*]
# ```
defmodule UniboV4.Accounting.GlAccount do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "accounting_gl_accounts"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_gl_account

    queries do
      get :get_accounting_gl_account, :read
      list :list_accounting_gl_accounts, :read
    end

    mutations do
      create :create_accounting_gl_account, :create
      update :update_accounting_gl_account, :update
      update :deactivate_accounting_gl_account, :deactivate
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :account_code, :string do
      allow_nil? false
      public? true
    end
    attribute :account_name, :string do
      allow_nil? false
      public? true
    end
    attribute :account_type, :atom do
      allow_nil? false
      constraints one_of: [:asset_receivable, :asset_payable, :asset_cash, :asset_bank, :asset_current, :asset_non_current, :asset_fixed, :asset_prepayments, :liability_current, :liability_non_current, :liability_payable, :liability_credit_card, :equity, :equity_unaffected, :income, :income_other, :expense, :expense_direct_cost, :expense_depreciation, :off_balance]
      public? true
    end
    attribute :reconcile, :boolean do
      default false
      public? true
    end
    attribute :parent_account_code, :string, public?: true
    attribute :description, :string, public?: true
    attribute :is_active, :boolean do
      default true
      public? true
    end
    attribute :currency_id, :uuid, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :parent_account, UniboV4.Accounting.GlAccount do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:account_code, :account_name, :account_type, :reconcile, :parent_account_code, :description, :currency_id]
      validate present(:account_code)
      validate present(:account_name)
      # TODO: 不支持的 action 内校验规则 custom
    end
    update :update do
      primary? true
      accept [:account_name, :description, :is_active, :parent_account_code, :reconcile, :currency_id]
      # skipped: validate custom : (incompatible with bulk update atomic path)
    end
    update :deactivate do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :is_active)
        if current == true do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :is_active, message: "must equal %{value}", vars: %{value: true}))
        end
      end
      # message: "只有活跃科目可以停用"
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:is_active, false)
      require_atomic? false
    end
  end

  identities do
    identity :unique_account_code, [:account_code]
  end

end
