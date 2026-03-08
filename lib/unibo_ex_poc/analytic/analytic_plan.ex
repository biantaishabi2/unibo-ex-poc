# Workflow: analytic_plan_lifecycle — 分析计划管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> deactivate
#   update --> update
#   update --> deactivate
#   deactivate --> [*]
# ```
defmodule UniboV4.Analytic.AnalyticPlan do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Analytic,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "分析维度计划，定义一套分析账户的分类维度（如\"项目\"、\"部门\"、\"成本类别\"）"
  end

  postgres do
    table "analytic_plans"
    repo UniboV4.Repo
  end

  graphql do
    type :analytic_analytic_plan

    queries do
      get :get_analytic_analytic_plan, :read
      list :list_analytic_analytic_plans, :read
    end

    mutations do
      create :create_analytic_analytic_plan, :create
      update :update_analytic_analytic_plan, :update
      update :deactivate_analytic_analytic_plan, :deactivate
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "计划名称（如\"项目维度\"、\"部门维度\"）"
    end
    attribute :code, :string do
      public? true
      description "计划编码，用于快速引用"
    end
    attribute :description, :string do
      public? true
      description "计划说明"
    end
    attribute :color, :integer do
      default 0
      public? true
      description "看板颜色（UI 标识）"
    end
    attribute :default_applicability, :atom do
      constraints one_of: [:optional, :mandatory, :unavailable]
      default :optional
      public? true
      description "在凭证分录行中的默认适用性：
optional = 可填可不填
mandatory = 必填
unavailable = 本计划不在该场景下显示
"
    end
    attribute :is_active, :boolean do
      default true
      public? true
      description "是否启用；停用后不允许新建该计划下的分析账户"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :accounts, UniboV4.Analytic.AnalyticAccount do
      public? true
      destination_attribute :plan_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :code, :description, :color, :default_applicability]
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :code, :description, :color, :default_applicability, :is_active]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :deactivate do
      description "停用分析计划"
      accept []
      change set_attribute(:is_active, false)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_plan_code, [:code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
