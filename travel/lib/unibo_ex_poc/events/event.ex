# Workflow: event_lifecycle — 活动完整生命周期流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> publish
#   create --> destroy
#   publish --> update
#   publish --> start
#   publish --> cancel
#   start --> complete
#   start --> cancel
#   complete --> archive
#   cancel --> archive
#   cancel --> destroy
#   archive --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.Events.Event do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Events,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource],
    notifiers: [UniboExPoc.Events.Event.Notifier]

  resource do
    description "活动主数据，管理线下/线上活动的完整生命周期"
  end

  postgres do
    table "events_events"
    repo UniboExPoc.Repo
  end

  graphql do
    type :events_event

    queries do
      get :get_events_event, :read
      list :list_events_events, :read
    end

    mutations do
      create :create_events_event, :create
      update :update_events_event, :update
      update :publish_events_event, :publish
      update :start_events_event, :start
      update :complete_events_event, :complete
      update :cancel_events_event, :cancel
      update :archive_events_event, :archive
      destroy :delete_events_event, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "活动名称（对应 work_effort_name）"
    end
    attribute :description, :string do
      public? true
      description "活动描述"
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:draft, :published, :ongoing, :completed, :cancelled, :archived]
      default :draft
      public? true
      description "活动状态（对应 current_status_id）"
    end
    attribute :start_date, :utc_datetime do
      allow_nil? false
      public? true
      description "活动开始时间（对应 estimated_start_date）"
    end
    attribute :end_date, :utc_datetime do
      allow_nil? false
      public? true
      description "活动结束时间（对应 estimated_completion_date）"
    end
    attribute :actual_start_date, :utc_datetime do
      public? true
      description "实际开始时间"
    end
    attribute :actual_end_date, :utc_datetime do
      public? true
      description "实际结束时间"
    end
    attribute :location, :string do
      public? true
      description "活动地点描述（对应 location_desc）"
    end
    attribute :capacity, :integer do
      public? true
      description "最大参与人数"
    end
    attribute :registration_deadline, :utc_datetime do
      public? true
      description "报名截止时间"
    end
    attribute :is_online, :boolean do
      default false
      public? true
      description "是否为线上活动"
    end
    attribute :cover_image_url, :string do
      public? true
      description "活动封面图URL"
    end
    attribute :detail_url, :string do
      public? true
      description "活动详情页/报名链接（外部落地页或内部详情路由）"
    end
    attribute :streaming_url, :string do
      public? true
      description "线上活动直播/会议链接（仅 is_online=true 时有意义）"
    end
    attribute :priority, :integer do
      default 0
      public? true
      description "活动优先级"
    end
    attribute :send_notification_email, :boolean do
      default true
      public? true
      description "是否发送通知邮件"
    end
    attribute :total_budget, :decimal do
      public? true
      description "活动预算上限（对应 total_money_allowed）"
    end
    attribute :budget_currency_id, :string do
      public? true
      description "预算币种（对应 money_uom_id）"
    end
    attribute :special_terms, :string do
      public? true
      description "参与条款/须知"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :event_type, UniboExPoc.Events.EventType do
      public? true
      allow_nil? false
    end
    has_many :registrations, UniboExPoc.Events.EventRegistration do
      public? true
      source_attribute :parent_event_id
      destination_attribute :event_id
    end
    has_many :tickets, UniboExPoc.Events.EventTicket do
      public? true
      source_attribute :parent_event_id
      destination_attribute :event_id
    end
    has_many :booths, UniboExPoc.Events.EventBooth do
      public? true
      source_attribute :parent_event_id
      destination_attribute :event_id
    end
    has_many :stages, UniboExPoc.Events.EventStage do
      public? true
      source_attribute :parent_event_id
      destination_attribute :event_id
    end
    belongs_to :parent_event, UniboExPoc.Events.Event do
      public? true
    end
    has_many :sub_events, UniboExPoc.Events.Event do
      public? true
      source_attribute :parent_event_id
      destination_attribute :parent_event_id
    end
    belongs_to :venue, UniboExPoc.Events.Facility do
      public? true
    end
    belongs_to :organizer, UniboExPoc.Events.Party do
      public? true
      source_attribute :organizer_party_id
    end
    has_many :translations, UniboExPoc.Events.EventTranslation, public?: true
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :description, :event_type_id, :start_date, :end_date, :location, :venue_id, :capacity, :registration_deadline, :is_online, :cover_image_url, :detail_url, :streaming_url, :priority, :parent_event_id, :send_notification_email, :total_budget, :budget_currency_id, :special_terms]
      argument :organizer_id, :uuid
      argument :event_type_id, :uuid, allow_nil?: false
      change manage_relationship(:event_type_id, :event_type, type: :append, on_lookup: :relate)
      validate present(:name)
      validate present(:start_date)
      validate present(:end_date)
      validate present(:event_type_id)
      # WARNING: compare :end_date 参数无法识别，请检查 YAML 定义
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :description, :event_type_id, :start_date, :end_date, :location, :venue_id, :capacity, :registration_deadline, :is_online, :cover_image_url, :detail_url, :streaming_url, :priority, :send_notification_email, :total_budget, :budget_currency_id, :special_terms]
      argument :organizer_id, :uuid
      # skipped: validate compare :end_date (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :publish do
      description "发布活动，开放报名通道（draft -> published）"
      accept []
      # skipped: validate compare :end_date (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态的活动可以发布"
      change set_attribute(:status, :published)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :start do
      description "开始活动（published -> ongoing）"
      accept []
      # skipped: validate compare :end_date (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :published do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :published}))
        end
      end
      # message: "只有已发布状态的活动可以开始"
      change set_attribute(:status, :ongoing)
      change UniboExPoc.Events.Changes.Event.ComputeActualStartDate
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :complete do
      description "完成活动（ongoing -> completed）"
      accept []
      # skipped: validate compare :end_date (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :ongoing do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :ongoing}))
        end
      end
      # message: "只有进行中状态的活动可以完成"
      change set_attribute(:status, :completed)
      change UniboExPoc.Events.Changes.Event.ComputeActualEndDate
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :cancel do
      description "取消活动，通知所有报名者（published/ongoing -> cancelled）"
      accept []
      # skipped: validate compare :end_date (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:published, :ongoing] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:published, :ongoing]}))
        end
      end
      # message: "只有已发布或进行中的活动可以取消"
      change set_attribute(:status, :cancelled)
      change UniboExPoc.Events.Changes.Event.CancelCall7
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :archive do
      description "归档活动（completed/cancelled -> archived）"
      accept []
      # skipped: validate compare :end_date (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:completed, :cancelled] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:completed, :cancelled]}))
        end
      end
      # message: "只有已完成或已取消的活动可以归档"
      change set_attribute(:status, :archived)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    destroy :destroy do
      description "删除活动（仅 draft 状态）"
      validate attribute_in(:status, [:draft, :cancelled])
      # message: "只有草稿或已取消状态的活动可以删除"
      change set_attribute(:id, expr(id))
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:registrations, :tickets, :booths, :stages, :sub_events]
  end

end
