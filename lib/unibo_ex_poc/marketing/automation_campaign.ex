# Workflow: automation_campaign_lifecycle — 自动化活动生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> start_campaign
#   update --> start_campaign
#   start_campaign --> stop_campaign
#   stop_campaign --> [*]
# ```
defmodule UniboExPoc.Marketing.AutomationCampaign do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Marketing.AutomationCampaign.Notifier]

  resource do
    description "营销自动化活动（工作流编排引擎）"
  end

  postgres do
    table "marketing_automation_campaigns"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_automation_campaign

    queries do
      get :get_marketing_automation_campaign, :read
      list :list_marketing_automation_campaigns, :read
    end

    mutations do
      create :create_marketing_automation_campaign, :create
      update :update_marketing_automation_campaign, :update
      update :start_campaign_marketing_automation_campaign, :start_campaign
      update :stop_campaign_marketing_automation_campaign, :stop_campaign
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "活动名称"
    end
    attribute :state, :atom do
      constraints one_of: [:draft, :running, :stopped, :done]
      default :draft
      public? true
    end
    attribute :model_id, :uuid do
      allow_nil? false
      public? true
      description "目标受众模型（crm.lead / res.partner / mailing.contact）"
    end
    attribute :domain_filter, :string do
      public? true
      description "受众动态筛选条件"
    end
    attribute :unique_field_id, :uuid do
      public? true
      description "去重字段，防止同一记录重复参与"
    end
    attribute :allow_restart, :boolean do
      default false
      public? true
      description "是否允许已完成参与者重新进入（rotation 递增）"
    end
    attribute :category_id, :uuid do
      public? true
      description "活动分类"
    end
    attribute :canvas_settings, :string do
      public? true
      description "前端可视化编辑器画布数据"
    end
    attribute :sync_last_date, :utc_datetime do
      public? true
      description "上次受众同步时间戳"
    end
    attribute :fixed_cost, :decimal do
      public? true
      description "固定成本（ROI 计算用）"
    end
    attribute :publish_up, :utc_datetime do
      public? true
      description "定时发布时间"
    end
    attribute :publish_down, :utc_datetime do
      public? true
      description "定时下线时间"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :activities, UniboExPoc.Marketing.AutomationActivity do
      public? true
      destination_attribute :campaign_id
    end
    has_many :participants, UniboExPoc.Marketing.AutomationParticipant do
      public? true
      destination_attribute :campaign_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :model_id, :domain_filter, :unique_field_id, :allow_restart, :category_id, :fixed_cost, :publish_up, :publish_down]
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :domain_filter, :unique_field_id, :allow_restart, :category_id, :canvas_settings, :fixed_cost, :publish_up, :publish_down]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :start_campaign do
      description "启动自动化活动（draft/stopped → running）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current in [:draft, :stopped] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must be one of %{values}", vars: %{values: [:draft, :stopped]}))
        end
      end
      # message: "只有草稿或已停止状态可以启动"
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate present : (incompatible with bulk update atomic path)
      change set_attribute(:state, :running)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :stop_campaign do
      description "停止自动化活动（running → stopped）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :running do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :running}))
        end
      end
      # message: "只有运行中状态可以停止"
      change set_attribute(:state, :stopped)
      change UniboExPoc.Marketing.Changes.AutomationCampaign.StopCampaignCall3
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
