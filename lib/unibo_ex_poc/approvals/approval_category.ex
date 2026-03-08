# Workflow: approval_category_lifecycle_flow — 审批类型完整生命周期流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   deactivate --> [*]
#   activate --> [*]
# ```
# Workflow: approval_category_deactivate_flow — 审批类型停用流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   deactivate --> [*]
# ```
defmodule UniboV4.Approvals.ApprovalCategory do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Approvals,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "审批类型配置，定义审批规则、表单字段和审批人模板"
  end

  postgres do
    table "approvals_approval_categories"
    repo UniboV4.Repo
  end

  graphql do
    type :approvals_approval_category

    queries do
      get :get_approvals_approval_category, :read
      list :list_approvals_approval_categorys, :read
    end

    mutations do
      create :create_approvals_approval_category, :create
      update :update_approvals_approval_category, :update
      update :activate_approvals_approval_category, :activate
      update :deactivate_approvals_approval_category, :deactivate
    end

  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      generated? true
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
      description "审批类型名称"
    end
    attribute :description, :string do
      public? true
      description "类型描述"
    end
    attribute :sequence_code, :string do
      public? true
      description "自动编号前缀"
    end
    attribute :automated_sequence, :boolean do
      allow_nil? false
      default false
      public? true
      description "是否启用自动编号"
    end
    attribute :approval_minimum, :integer do
      allow_nil? false
      public? true
      description "最少需通过审批人数"
    end
    attribute :manager_approval, :atom do
      allow_nil? false
      constraints one_of: [:required, :optional, :none]
      default :none
      public? true
      description "经理审批角色"
    end
    attribute :is_active, :boolean do
      allow_nil? false
      default true
      public? true
      description "软删除/停用标志"
    end
    attribute :exclusive_user, :boolean do
      allow_nil? false
      default false
      public? true
      description "是否禁止自审自批"
    end
    attribute :requester_document, :string do
      public? true
      description "附件说明提示"
    end
    attribute :field_config, :string do
      public? true
      description "动态表单字段配置（has_date, has_amount 等，值为 required/optional/no）"
    end
    attribute :approval_mode, :atom do
      constraints one_of: [:parallel, :sequential, :hybrid]
      default :parallel
      public? true
      description "多人审批执行模式（Phase 2）"
    end
    attribute :routing_rules, :string do
      public? true
      description "条件路由配置（Phase 2）"
    end
    attribute :escalation_config, :string do
      public? true
      description "超时升级配置（Phase 3）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :company, UniboV4.Approvals.Party do
      public? true
      allow_nil? false
      source_attribute :company_party_id
    end
    has_many :approval_requests, UniboV4.Approvals.ApprovalRequest do
      public? true
      source_attribute :company_party_id
      destination_attribute :category_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :description, :sequence_code, :automated_sequence, :approval_minimum, :manager_approval, :exclusive_user, :requester_document, :field_config, :approval_mode, :routing_rules, :escalation_config]
      argument :company_id, :integer, allow_nil?: false
      change manage_relationship(:company_id, :company, type: :append, on_lookup: :relate)
      validate present(:name)
      # validation: valid_field_config
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :description, :sequence_code, :automated_sequence, :approval_minimum, :manager_approval, :exclusive_user, :requester_document, :field_config, :approval_mode, :routing_rules, :escalation_config]
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :activate do
      description "启用审批类型"
      accept []
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :is_active)
        if current == false do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :is_active, message: "must equal %{value}", vars: %{value: false}))
        end
      end
      # message: "只有停用状态可以启用"
      change set_attribute(:is_active, true)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :deactivate do
      description "停用审批类型"
      accept []
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :is_active)
        if current == true do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :is_active, message: "must equal %{value}", vars: %{value: true}))
        end
      end
      # message: "只有启用状态可以停用"
      change set_attribute(:is_active, false)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate compare(:approval_minimum, greater_than_or_equal_to: 0)
  end

  identities do
    identity :unique_name_per_company, [:name, :company_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
