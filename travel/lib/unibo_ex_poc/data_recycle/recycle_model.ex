# Workflow: recycle_model_lifecycle — 回收规则维护与执行流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> recycle_records_action
#   create --> cron_recycle
#   create --> destroy
#   update --> update
#   update --> recycle_records_action
#   update --> cron_recycle
#   update --> destroy
#   recycle_records_action --> update
#   recycle_records_action --> cron_recycle
#   recycle_records_action --> destroy
#   cron_recycle --> update
#   cron_recycle --> recycle_records_action
#   cron_recycle --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.DataRecycle.RecycleModel do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.DataRecycle,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "回收规则配置——定义哪些模型的数据需要按时间维度进行回收（归档或删除）"
  end

  postgres do
    table "data_recycle_recycle_models"
    repo UniboExPoc.Repo
  end

  graphql do
    type :data_recycle_recycle_model

    queries do
      get :get_data_recycle_recycle_model, :read
      list :list_data_recycle_recycle_models, :read
    end

    mutations do
      create :create_data_recycle_recycle_model, :create
      update :update_data_recycle_recycle_model, :update
      update :recycle_records_action_data_recycle_recycle_model, :recycle_records_action
      update :cron_recycle_data_recycle_recycle_model, :cron_recycle
      destroy :delete_data_recycle_recycle_model, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "规则名称"
    end
    attribute :res_model_name, :string do
      allow_nil? false
      public? true
      description "目标模型名称（如 sale.order）"
    end
    attribute :domain, :string do
      public? true
      description "过滤条件（JSON 格式域表达式）"
    end
    attribute :time_field, :string do
      allow_nil? false
      public? true
      description "用于判断过期的时间字段名（如 create_date、write_date）"
    end
    attribute :time_field_delta, :integer do
      allow_nil? false
      default 1
      public? true
      description "时间差值"
    end
    attribute :time_field_delta_unit, :atom do
      constraints one_of: [:days, :weeks, :months, :years]
      default :months
      public? true
      description "时间差值单位"
    end
    attribute :recycle_mode, :atom do
      constraints one_of: [:manual, :automatic]
      default :manual
      public? true
      description "回收模式；manual 需人工确认，automatic 由定时任务自动执行"
    end
    attribute :recycle_action, :atom do
      constraints one_of: [:archive, :delete]
      default :archive
      public? true
      description "回收动作；archive 归档（soft delete），delete 物理删除"
    end
    attribute :include_archived, :boolean do
      default false
      public? true
      description "是否包含已归档记录"
    end
    attribute :active, :boolean do
      default true
      public? true
      description "是否启用"
    end
    attribute :notify_frequency, :integer do
      default 1
      public? true
      description "通知频率数值"
    end
    attribute :notify_frequency_period, :atom do
      constraints one_of: [:days, :weeks, :months]
      default :weeks
      public? true
      description "通知频率单位"
    end
    attribute :last_notification, :utc_datetime do
      public? true
      description "上次通知时间"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  calculations do
    calculate :records_to_recycle_count, :integer, expr("count(recycle_records)")
  end

  relationships do
    has_many :recycle_records, UniboExPoc.DataRecycle.RecycleRecord do
      public? true
    end
    many_to_many :notify_users, UniboExPoc.DataRecycle.Party do
      public? true
      through UniboExPoc.DataRecycle.RecycleModelNotifyUser
      destination_attribute_on_join_resource :user_party_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :res_model_name, :domain, :time_field, :time_field_delta, :time_field_delta_unit, :recycle_mode, :recycle_action, :include_archived, :active, :notify_frequency, :notify_frequency_period]
      validate present(:name)
      validate present(:res_model_name)
      validate present(:time_field)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :res_model_name, :domain, :time_field, :time_field_delta, :time_field_delta_unit, :recycle_mode, :recycle_action, :include_archived, :active, :notify_frequency, :notify_frequency_period]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :recycle_records_action do
      description "手动触发回收——根据规则搜索符合条件的记录，自动模式直接执行，手动模式创建待审记录"
      accept []
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :cron_recycle do
      description "定时任务入口——扫描所有启用的规则并执行回收"
      accept []
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate one_of(:recycle_action, [:archive, :delete])
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:recycle_records]
  end

end
