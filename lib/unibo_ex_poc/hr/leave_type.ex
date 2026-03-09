# Workflow: leave_type_write_flow — LeaveType 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.HR.LeaveType do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "假期类型（配置实体）"
  end

  postgres do
    table "hr_leave_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :hr_leave_type

    queries do
      get :get_hr_leave_type, :read
      list :list_hr_leave_types, :read
    end

    mutations do
      create :create_hr_leave_type, :create
      update :update_hr_leave_type, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "假期名称，如\"年假\"、\"病假\""
    end
    attribute :code, :string do
      allow_nil? false
      public? true
      description "唯一编码"
    end
    attribute :max_days_per_year, :decimal do
      public? true
      description "年度最大天数，null 表示不限额"
    end
    attribute :is_paid, :boolean do
      default true
      public? true
      description "是否带薪"
    end
    attribute :requires_allocation, :atom do
      constraints one_of: [:yes, :no]
      default :no
      public? true
      description "是否需要额度分配"
    end
    attribute :leave_validation_type, :atom do
      constraints one_of: [:no_validation, :manager, :hr, :both]
      default :manager
      public? true
      description "审批流类型，决定 LeaveRequest 的审批流走向"
    end
    attribute :allows_negative, :boolean do
      default false
      public? true
      description "是否允许负余额"
    end
    attribute :max_allowed_negative, :decimal do
      public? true
      description "最大负余额天数"
    end
    attribute :request_unit, :atom do
      constraints one_of: [:day, :half_day, :hour]
      default :day
      public? true
      description "请假单位"
    end
    attribute :create_calendar_meeting, :boolean do
      default false
      public? true
      description "审批通过后是否创建日历事件"
    end
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :leave_requests, UniboExPoc.HR.LeaveRequest do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :code, :max_days_per_year, :is_paid, :requires_allocation, :leave_validation_type, :allows_negative, :max_allowed_negative, :request_unit, :create_calendar_meeting, :description]
      validate present(:name)
      validate present(:code)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :max_days_per_year, :is_paid, :requires_allocation, :leave_validation_type, :allows_negative, :max_allowed_negative, :request_unit, :create_calendar_meeting, :description]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_leave_type_code, [:code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
