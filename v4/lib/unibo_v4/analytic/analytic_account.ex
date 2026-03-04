# Workflow: analytic_account_lifecycle — 分析账户管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> deactivate
#   update --> update
#   update --> deactivate
#   deactivate --> [*] : deactivated
# ```
defmodule UniboV4.Analytic.AnalyticAccount do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Analytic,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.Analytic.AnalyticAccount.Notifier]

  postgres do
    table "analytic_accounts"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :code, :string, public?: true
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :date_start, :date, public?: true
    attribute :date_stop, :date, public?: true
    attribute :is_active, :boolean do
      default true
      public? true
    end
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :balance
    # TODO: 不支持的 calculation 表达式 :debit
    # TODO: 不支持的 calculation 表达式 :credit
  end

  relationships do
    belongs_to :plan, UniboV4.Analytic.AnalyticPlan do
      public? true
      allow_nil? false
    end
    belongs_to :parent, UniboV4.Analytic.AnalyticAccount do
      public? true
    end
    has_many :children, UniboV4.Analytic.AnalyticAccount do
      public? true
      destination_attribute :parent_id
    end
    belongs_to :partner, UniboV4.Analytic.Partner do
      public? true
    end
    has_many :analytic_lines, UniboV4.Analytic.AnalyticLine do
      public? true
      destination_attribute :account_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:code, :name, :date_start, :date_stop, :description]
      argument :plan_id, :uuid, allow_nil?: false
      change manage_relationship(:plan_id, :plan, type: :append, on_lookup: :relate)
      validate present(:name)
      validate present(:plan_id)
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 action 内校验规则 custom
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
      accept [:code, :name, :date_start, :date_stop, :description, :is_active]
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
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
    update :deactivate do
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:is_active, false)
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

  identities do
    identity :unique_code_per_plan, [:plan_id, :code]
  end

end
