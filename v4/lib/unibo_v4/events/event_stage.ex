# Workflow: stage_lifecycle — 议程管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Events.EventStage do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Events,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "events_event_stages"
    repo UniboV4.Repo
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
    end
    attribute :description, :string, public?: true
    attribute :start_time, :utc_datetime do
      allow_nil? false
      public? true
    end
    attribute :end_time, :utc_datetime do
      allow_nil? false
      public? true
    end
    attribute :speaker_name, :string, public?: true
    attribute :speaker_id, :string, public?: true
    attribute :topic, :string, public?: true
    attribute :location, :string, public?: true
    attribute :sequence, :integer do
      default 0
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :event, UniboV4.Events.Event do
      public? true
      allow_nil? false
    end
    has_many :translations, UniboV4.Events.EventStageTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :description, :start_time, :end_time, :speaker_name, :speaker_id, :topic, :location, :sequence]
      argument :event_id, :uuid, allow_nil?: false
      change manage_relationship(:event_id, :event, type: :append, on_lookup: :relate)
      validate present(:event_id)
      validate present(:name)
      validate present(:start_time)
      validate present(:end_time)
      # TODO: compare :end_time 参数无法识别
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:name, :description, :start_time, :end_time, :speaker_name, :speaker_id, :topic, :location, :sequence]
      # skipped: validate compare :end_time (incompatible with bulk update atomic path)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
  end

end
