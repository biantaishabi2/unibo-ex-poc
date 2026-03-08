# Workflow: work_center_status_flow — 工作中心创建、维护与阻塞状态切换流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   block --> [*]
#   unblock --> [*]
# ```
defmodule UniboV4.Manufacturing.WorkCenter do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "工作中心"
  end

  postgres do
    table "manufacturing_work_centers"
    repo UniboV4.Repo
  end

  graphql do
    type :manufacturing_work_center

    queries do
      get :get_manufacturing_work_center, :read
      list :list_manufacturing_work_centers, :read
    end

    mutations do
      create :create_manufacturing_work_center, :create
      update :update_manufacturing_work_center, :update
      update :block_manufacturing_work_center, :block
      update :unblock_manufacturing_work_center, :unblock
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :center_code, :string do
      allow_nil? false
      public? true
      description "工作中心编号"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
      description "工作中心名称"
    end
    attribute :costs_hour, :decimal do
      default 0
      public? true
      description "每小时成本"
    end
    attribute :capacity, :decimal do
      default 1.0
      public? true
      description "产能（单位/周期）"
    end
    attribute :time_start, :decimal do
      default 0
      public? true
      description "设置时间（分钟）"
    end
    attribute :time_stop, :decimal do
      default 0
      public? true
      description "清理时间（分钟）"
    end
    attribute :time_efficiency, :decimal do
      default 100
      public? true
      description "效率因子（百分比，100=100%）"
    end
    attribute :resource_calendar_id, :uuid do
      public? true
      description "工作日历 ID（关联 Resource 模块）"
    end
    attribute :blocked, :boolean do
      default false
      public? true
      description "是否被阻塞（阻塞时不可启动工单）"
    end
    attribute :status, :atom do
      constraints one_of: [:active, :inactive, :maintenance]
      default :active
      public? true
    end
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :work_orders, UniboV4.Manufacturing.WorkOrder do
      public? true
    end
    has_many :productivity_records, UniboV4.Manufacturing.WorkcenterProductivity do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:center_code, :name, :costs_hour, :capacity, :time_start, :time_stop, :time_efficiency, :resource_calendar_id, :description]
      validate present(:center_code)
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :costs_hour, :capacity, :time_start, :time_stop, :time_efficiency, :resource_calendar_id, :status, :blocked, :description]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :block do
      description "阻塞工作中心"
      accept []
      change set_attribute(:blocked, true)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :unblock do
      description "解除阻塞"
      accept []
      change set_attribute(:blocked, false)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate compare(:capacity, greater_than: 0)
    validate compare(:time_efficiency, greater_than: 0)
  end

  identities do
    identity :unique_center_code, [:center_code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
