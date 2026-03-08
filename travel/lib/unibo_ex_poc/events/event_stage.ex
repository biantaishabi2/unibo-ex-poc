# Workflow: stage_lifecycle — 议程管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.Events.EventStage do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Events,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "活动阶段/议程，定义活动的时间轴和演讲安排"
  end

  postgres do
    table "events_event_stages"
    repo UniboExPoc.Repo
  end

  graphql do
    type :events_event_stage

    queries do
      get :get_events_event_stage, :read
      list :list_events_event_stages, :read
    end

    mutations do
      create :create_events_event_stage, :create
      update :update_events_event_stage, :update
      destroy :delete_events_event_stage, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "阶段/议程名称"
    end
    attribute :description, :string do
      public? true
      description "阶段描述"
    end
    attribute :start_time, :utc_datetime do
      allow_nil? false
      public? true
      description "开始时间"
    end
    attribute :end_time, :utc_datetime do
      allow_nil? false
      public? true
      description "结束时间"
    end
    attribute :speaker_name, :string do
      public? true
      description "演讲者姓名"
    end
    attribute :topic, :string do
      public? true
      description "演讲主题"
    end
    attribute :location, :string do
      public? true
      description "分会场/房间"
    end
    attribute :sequence, :integer do
      default 0
      public? true
      description "排序序号"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :event, UniboExPoc.Events.Event do
      public? true
      allow_nil? false
    end
    belongs_to :speaker, UniboExPoc.Events.Party do
      public? true
      source_attribute :speaker_party_id
    end
    has_many :translations, UniboExPoc.Events.EventStageTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:event_id, :name, :description, :start_time, :end_time, :speaker_name, :topic, :location, :sequence]
      argument :speaker_id, :uuid
      argument :event_id, :uuid, allow_nil?: false
      change manage_relationship(:event_id, :event, type: :append, on_lookup: :relate)
      validate present(:event_id)
      validate present(:name)
      validate present(:start_time)
      validate present(:end_time)
      # WARNING: compare :end_time 参数无法识别，请检查 YAML 定义
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :description, :start_time, :end_time, :speaker_name, :topic, :location, :sequence]
      argument :speaker_id, :uuid
      # skipped: validate compare :end_time (incompatible with bulk update atomic path)
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
  end

end
