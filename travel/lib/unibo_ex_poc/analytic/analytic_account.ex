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
defmodule UniboExPoc.Analytic.AnalyticAccount do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Analytic,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Analytic.AnalyticAccount.Notifier]

  resource do
    description "分析账户（成本中心/利润中心/项目账户），支持多级层级，归属于某一 AnalyticPlan"
  end

  postgres do
    table "analytic_accounts"
    repo UniboExPoc.Repo
  end

  graphql do
    type :analytic_analytic_account

    queries do
      get :get_analytic_analytic_account, :read
      list :list_analytic_analytic_accounts, :read
    end

    mutations do
      create :create_analytic_analytic_account, :create
      update :update_analytic_analytic_account, :update
      update :deactivate_analytic_analytic_account, :deactivate
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :code, :string do
      public? true
      description "分析账户编码 [R-ANL-001]"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
      description "分析账户名称（如\"华南大区项目\"、\"研发部门\"）"
    end
    attribute :date_start, :date do
      public? true
      description "有效期开始（来自 GlAccountOrganization.from_date）"
    end
    attribute :date_stop, :date do
      public? true
      description "有效期结束（来自 GlAccountOrganization.thru_date）"
    end
    attribute :is_active, :boolean do
      default true
      public? true
      description "是否启用；停用后不可用于新 AnalyticLine [R-ANL-003]"
    end
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :balance, :decimal, expr(sum_related(analytic_lines, amount))
    calculate :debit, :decimal, expr(sum_related_filtered(analytic_lines, amount, amount > 0))
    calculate :credit, :decimal, expr(sum_related_filtered(analytic_lines, amount, amount < 0))
  end

  relationships do
    belongs_to :plan, UniboExPoc.Analytic.AnalyticPlan do
      public? true
      allow_nil? false
    end
    belongs_to :parent, UniboExPoc.Analytic.AnalyticAccount do
      public? true
    end
    has_many :children, UniboExPoc.Analytic.AnalyticAccount do
      public? true
      source_attribute :parent_id
      destination_attribute :parent_id
    end
    belongs_to :partner, UniboExPoc.Analytic.Party do
      public? true
      source_attribute :partner_party_id
    end
    has_many :analytic_lines, UniboExPoc.Analytic.AnalyticLine do
      public? true
      source_attribute :parent_id
      destination_attribute :account_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:code, :name, :plan_id, :parent_id, :date_start, :date_stop, :description]
      argument :partner_id, :uuid
      argument :plan_id, :uuid, allow_nil?: false
      change manage_relationship(:plan_id, :plan, type: :append, on_lookup: :relate)
      validate present(:name)
      validate present(:plan_id)
      validate attribute_does_not_equal(:parent_id, ::id)
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
      accept [:code, :name, :parent_id, :date_start, :date_stop, :description, :is_active]
      argument :partner_id, :uuid
      # skipped: validate compare :parent_id (incompatible with bulk update atomic path)
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
      description "停用分析账户 [R-ANL-003]"
      accept []
      # skipped: validate compare :parent_id (incompatible with bulk update atomic path)
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
