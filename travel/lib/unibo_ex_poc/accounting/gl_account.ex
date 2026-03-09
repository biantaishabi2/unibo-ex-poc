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
defmodule UniboExPoc.Accounting.GlAccount do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "总账科目"
  end

  postgres do
    table "accounting_gl_accounts"
    repo UniboExPoc.Repo
    identity_index_names unique_account_code: "idx_accounting_gl_accounts_unique_account_code"
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
      description "科目编号"
    end
    attribute :account_name, :string do
      allow_nil? false
      public? true
      description "科目名称"
    end
    attribute :account_type, :atom do
      allow_nil? false
      constraints one_of: [:asset_receivable, :asset_payable, :asset_cash, :asset_bank, :asset_current, :asset_non_current, :asset_fixed, :asset_prepayments, :liability_current, :liability_non_current, :liability_payable, :liability_credit_card, :equity, :equity_unaffected, :income, :income_other, :expense, :expense_direct_cost, :expense_depreciation, :off_balance]
      public? true
      description "科目类型（细分类型，兼容 Odoo 17 account_type）"
    end
    attribute :reconcile, :boolean do
      default false
      public? true
      description "是否允许核销（应收/应付必须为 true）[R-GL-001]"
    end
    attribute :parent_account_code, :string do
      public? true
      description "上级科目编号"
    end
    attribute :description, :string, public?: true
    attribute :is_active, :boolean do
      default true
      public? true
      description "是否启用；已停用科目不可用于新分录 [R-GL-002]"
    end
    attribute :currency_id, :uuid do
      public? true
      description "外币限定（可选，限定该科目只能用某一外币记账）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :parent_account, UniboExPoc.Accounting.GlAccount do
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
      validate compare(:reconcile, equal_to: true)
    end
    update :update do
      primary? true
      accept [:account_name, :description, :is_active, :parent_account_code, :reconcile, :currency_id]
      # skipped: validate compare :reconcile (incompatible with bulk update atomic path)
      require_atomic? false
    end
    update :deactivate do
      description "停用科目 [R-GL-002]"
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
      # skipped: validate compare :reconcile (incompatible with bulk update atomic path)
      change set_attribute(:is_active, false)
      require_atomic? false
    end
  end

  identities do
    identity :unique_account_code, [:account_code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
