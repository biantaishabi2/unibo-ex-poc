# Workflow: quality_point_lifecycle — 质量控制点生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> activate
#   create --> deactivate
#   create --> trigger_checks
#   update --> deactivate
#   update --> trigger_checks
#   deactivate --> activate
#   activate --> update
#   activate --> deactivate
#   activate --> trigger_checks
#   trigger_checks --> [*]
# ```
defmodule UniboExPoc.Quality.QualityPoint do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Quality,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "质量控制点，定义何时、对什么产品、执行哪种检查，自动触发生成 QualityCheck"
  end

  postgres do
    table "quality_points"
    repo UniboExPoc.Repo
  end

  graphql do
    type :quality_quality_point

    queries do
      get :get_quality_quality_point, :read
      list :list_quality_quality_points, :read
    end

    mutations do
      create :create_quality_quality_point, :create
      update :update_quality_quality_point, :update
      update :activate_quality_quality_point, :activate
      update :deactivate_quality_quality_point, :deactivate
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :title, :string do
      allow_nil? false
      public? true
      description "控制点名称"
    end
    attribute :operation_type, :atom do
      allow_nil? false
      constraints one_of: [:receipt, :manufacturing, :delivery, :internal_transfer]
      public? true
      description "操作类型，必须与触发单据类型一致"
    end
    attribute :check_type, :atom do
      allow_nil? false
      constraints one_of: [:pass_fail, :measure, :picture, :instructions, :worksheet, :print_label]
      public? true
      description "检查类型"
    end
    attribute :control_per, :atom do
      allow_nil? false
      constraints one_of: [:operation, :product, :quantity]
      default :operation
      public? true
      description "控制粒度：operation=整单一次，product=每产品一次，quantity=按数量"
    end
    attribute :control_frequency, :atom do
      allow_nil? false
      constraints one_of: [:all, :random, :periodic]
      default :all
      public? true
      description "控制频率"
    end
    attribute :frequency_value, :decimal do
      public? true
      description "random 时=概率%，periodic 时=间隔次数"
    end
    attribute :norm_value, :decimal do
      public? true
      description "标准值（仅 measure 类型）"
    end
    attribute :tolerance_min, :decimal do
      public? true
      description "公差下限（仅 measure 类型）"
    end
    attribute :tolerance_max, :decimal do
      public? true
      description "公差上限（仅 measure 类型）"
    end
    attribute :instructions, :string do
      public? true
      description "检查说明/操作指引"
    end
    attribute :failure_action, :atom do
      allow_nil? false
      constraints one_of: [:block, :warn]
      default :warn
      public? true
      description "失败动作：block=阻塞单据，warn=仅告警"
    end
    attribute :active, :boolean do
      allow_nil? false
      default true
      public? true
      description "启用状态"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    many_to_many :product_ids, UniboExPoc.Quality.Product do
      public? true
      through UniboExPoc.Quality.QualityPointProductLink
    end
    belongs_to :work_order_operation, UniboExPoc.Quality.WorkOrderOperation do
      public? true
    end
    belongs_to :team, UniboExPoc.Quality.QualityTeam do
      public? true
    end
    belongs_to :responsible, UniboExPoc.Quality.Party do
      public? true
      source_attribute :responsible_party_id
    end
    belongs_to :worksheet_template, UniboExPoc.Quality.WorksheetTemplate do
      public? true
    end
    belongs_to :company, UniboExPoc.Quality.Party do
      public? true
      allow_nil? false
      source_attribute :company_party_id
    end
    has_many :checks, UniboExPoc.Quality.QualityCheck do
      public? true
      destination_attribute :point_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:title, :operation_type, :check_type, :control_per, :control_frequency, :frequency_value, :norm_value, :tolerance_min, :tolerance_max, :instructions, :failure_action, :active]
      argument :company_id, :uuid, allow_nil?: false
      argument :team_id, :uuid
      argument :responsible_id, :uuid
      argument :worksheet_template_id, :uuid
      argument :product_ids, {:array, :string}
      argument :work_order_operation_id, :uuid
      change manage_relationship(:company_id, :company, type: :append, on_lookup: :relate)
      validate present(:title)
      validate present(:operation_type)
      validate present(:check_type)
      validate present(:norm_value)
      # message: "measure 类型需要填写标准值"
      validate present(:tolerance_min)
      # message: "measure 类型需要填写公差下限"
      validate present(:tolerance_max)
      # message: "measure 类型需要填写公差上限"
      validate present(:worksheet_template_id)
      # message: "worksheet 类型需要选择工作表模板"
      validate present(:work_order_operation_id)
      # message: "工序关联仅在制造操作类型下有效"
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:title, :operation_type, :check_type, :control_per, :control_frequency, :frequency_value, :norm_value, :tolerance_min, :tolerance_max, :instructions, :failure_action, :active]
      # skipped: validate present :norm_value (incompatible with bulk update atomic path)
      # skipped: validate present :tolerance_min (incompatible with bulk update atomic path)
      # skipped: validate present :tolerance_max (incompatible with bulk update atomic path)
      # skipped: validate present :worksheet_template_id (incompatible with bulk update atomic path)
      # skipped: validate present :work_order_operation_id (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :activate do
      description "启用控制点"
      accept []
      # skipped: validate present :norm_value (incompatible with bulk update atomic path)
      # skipped: validate present :tolerance_min (incompatible with bulk update atomic path)
      # skipped: validate present :tolerance_max (incompatible with bulk update atomic path)
      # skipped: validate present :worksheet_template_id (incompatible with bulk update atomic path)
      # skipped: validate present :work_order_operation_id (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :active)
        if current == false do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :active, message: "must equal %{value}", vars: %{value: false}))
        end
      end
      # message: "只有已禁用的控制点可以启用"
      change set_attribute(:active, true)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :deactivate do
      description "禁用控制点"
      accept []
      # skipped: validate present :norm_value (incompatible with bulk update atomic path)
      # skipped: validate present :tolerance_min (incompatible with bulk update atomic path)
      # skipped: validate present :tolerance_max (incompatible with bulk update atomic path)
      # skipped: validate present :worksheet_template_id (incompatible with bulk update atomic path)
      # skipped: validate present :work_order_operation_id (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :active)
        if current == true do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :active, message: "must equal %{value}", vars: %{value: true}))
        end
      end
      # message: "只有已启用的控制点可以禁用"
      change set_attribute(:active, false)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    action :trigger_checks do
      description "根据匹配规则扫描并自动生成 QualityCheck"
      run fn input, _context ->
        :ok
      end
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
