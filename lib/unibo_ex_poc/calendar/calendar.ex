# Workflow: calendar_container_lifecycle_flow — 日历容器维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> update
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Calendar.Calendar do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Calendar,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "日历容器，个人/团队/资源日历的统一管理单元"
  end

  postgres do
    table "calendar_calendars"
    repo UniboExPoc.Repo
  end

  graphql do
    type :calendar_calendar

    queries do
      get :get_calendar_calendar, :read
      list :list_calendar_calendars, :read
    end

    mutations do
      create :create_calendar_calendar, :create
      update :update_calendar_calendar, :update
      destroy :delete_calendar_calendar, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "日历名称"
    end
    attribute :description, :string do
      public? true
      description "日历描述"
    end
    attribute :color, :integer do
      default 0
      public? true
      description "日历颜色索引"
    end
    attribute :calendar_type, :atom do
      allow_nil? false
      constraints one_of: [:personal, :team, :resource]
      default :personal
      public? true
      description "日历类型（个人/团队/资源）"
    end
    attribute :is_default, :boolean do
      default false
      public? true
      description "是否为默认日历"
    end
    attribute :active, :boolean do
      default true
      public? true
      description "是否启用"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :owner, UniboExPoc.Calendar.Party do
      public? true
      allow_nil? false
      source_attribute :owner_party_id
    end
    has_many :events, UniboExPoc.Calendar.CalendarEvent do
      public? true
      source_attribute :owner_party_id
      destination_attribute :calendar_id
    end
    has_many :translations, UniboExPoc.Calendar.CalendarTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :description, :color, :owner_party_id, :calendar_type, :is_default, :active]
      argument :owner_id, :uuid, allow_nil?: false
      change manage_relationship(:owner_id, :owner, type: :append, on_lookup: :relate)
      validate present(:name)
      validate present(:owner_party_id)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :description, :color, :calendar_type, :is_default, :active]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:events]
  end

end
