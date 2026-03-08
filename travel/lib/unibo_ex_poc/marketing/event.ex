# Workflow: event_lifecycle — 活动/展会生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> publish
#   update --> publish
#   publish --> complete
#   publish --> cancel
#   publish --> set_done
#   complete --> [*]
#   cancel --> [*]
#   set_done --> [*]
# ```
defmodule UniboExPoc.Marketing.Event do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "活动/展会"
  end

  postgres do
    table "marketing_events"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_event

    queries do
      get :get_marketing_event, :read
      list :list_marketing_events, :read
    end

    mutations do
      create :create_marketing_event, :create
      update :update_marketing_event, :update
      update :publish_marketing_event, :publish
      update :complete_marketing_event, :complete
      update :cancel_marketing_event, :cancel
      update :set_done_marketing_event, :set_done
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :event_code, :string do
      allow_nil? false
      public? true
      description "活动编号"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :published, :ongoing, :completed, :cancelled]
      default :draft
      public? true
    end
    attribute :stage_id, :uuid do
      public? true
      description "看板阶段（可选，用于 Kanban 看板展示）"
    end
    attribute :kanban_state, :atom do
      constraints one_of: [:normal, :done, :blocked]
      default :normal
      public? true
      description "看板状态，stage 变更时重置为 normal"
    end
    attribute :event_type_id, :uuid do
      public? true
      description "活动模板，提供默认值继承"
    end
    attribute :start_date, :utc_datetime, public?: true
    attribute :end_date, :utc_datetime, public?: true
    attribute :date_tz, :string do
      public? true
      description "时区"
    end
    attribute :location, :string, public?: true
    attribute :seats_max, :integer do
      default 0
      public? true
      description "最大席位（0=不限）"
    end
    attribute :seats_limited, :boolean do
      default false
      public? true
      description "是否限制人数"
    end
    attribute :auto_confirm, :boolean do
      default false
      public? true
      description "报名自动确认"
    end
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :registrations, UniboExPoc.Marketing.EventRegistration do
      public? true
    end
    has_many :tickets, UniboExPoc.Marketing.EventTicket do
      public? true
    end
    has_many :event_mails, UniboExPoc.Marketing.EventMailSchedule do
      public? true
    end
    has_many :booths, UniboExPoc.Marketing.EventBooth do
      public? true
      source_attribute :campaign_id
      destination_attribute :event_id
    end
    belongs_to :campaign, UniboExPoc.Marketing.Campaign do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:event_code, :name, :start_date, :end_date, :date_tz, :location, :seats_max, :seats_limited, :auto_confirm, :description, :event_type_id]
      argument :campaign_id, :uuid
      validate present(:event_code)
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :start_date, :end_date, :date_tz, :location, :seats_max, :seats_limited, :auto_confirm, :description, :stage_id, :event_type_id]
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:kanban_state, :normal)
      change UniboExPoc.Marketing.Changes.Event.UpdateCall5
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :publish do
      description "发布活动"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以发布"
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:status, :published)
      change set_attribute(:kanban_state, :normal)
      change UniboExPoc.Marketing.Changes.Event.PublishCall5
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :complete do
      description "完成活动"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:published, :ongoing] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:published, :ongoing]}))
        end
      end
      # message: "只有已发布或进行中状态可以完成"
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:status, :completed)
      change set_attribute(:kanban_state, :normal)
      change UniboExPoc.Marketing.Changes.Event.CompleteCall5
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :cancel do
      description "取消活动"
      accept []
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:status, :cancelled)
      change set_attribute(:kanban_state, :normal)
      change UniboExPoc.Marketing.Changes.Event.CancelCall5
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :set_done do
      description "跳转到 ended 阶段"
      accept []
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:status, :completed)
      change set_attribute(:kanban_state, :normal)
      change UniboExPoc.Marketing.Changes.Event.SetDoneCall5
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_event_code, [:event_code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
