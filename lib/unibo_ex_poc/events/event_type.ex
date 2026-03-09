# Workflow: event_type_lifecycle — 活动类型管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.Events.EventType do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Events,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "活动类型（会议/研讨会/展览/培训/网络研讨会）"
  end

  postgres do
    table "events_event_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :events_event_type

    queries do
      get :get_events_event_type, :read
      list :list_events_event_types, :read
    end

    mutations do
      create :create_events_event_type, :create
      update :update_events_event_type, :update
      destroy :delete_events_event_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "类型名称（对应 description）"
    end
    attribute :code, :string do
      allow_nil? false
      public? true
      description "类型编码（对应 work_effort_type_id），预置值：CONFERENCE/WORKSHOP/EXHIBITION/TRAINING/WEBINAR"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    has_many :events, UniboExPoc.Events.Event do
      public? true
      source_attribute :parent_type_id
      destination_attribute :event_type_id
    end
    has_many :children, UniboExPoc.Events.EventType do
      public? true
      source_attribute :parent_type_id
      destination_attribute :parent_type_id
    end
    belongs_to :parent_type, UniboExPoc.Events.EventType do
      public? true
    end
    has_many :translations, UniboExPoc.Events.EventTypeTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :code, :parent_type_id]
      validate present(:name)
      validate present(:code)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :parent_type_id]
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
    archive_related [:events, :children]
  end

end
