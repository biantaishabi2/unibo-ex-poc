# Workflow: event_type_booth_maintain_flow — 展位类型维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.Marketing.EventTypeBooth do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "活动类型展位模板，创建活动时自动同步"
  end

  postgres do
    table "marketing_event_type_booths"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_event_type_booth

    queries do
      get :get_marketing_event_type_booth, :read
      list :list_marketing_event_type_booths, :read
    end

    mutations do
      create :create_marketing_event_type_booth, :create
      update :update_marketing_event_type_booth, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "展位模板名称"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :event_type, UniboExPoc.Events.EventType do
      public? true
      allow_nil? false
    end
    belongs_to :booth_category, UniboExPoc.Marketing.EventBoothCategory do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name]
      argument :event_type_id, :uuid, allow_nil?: false
      argument :booth_category_id, :uuid, allow_nil?: false
      change manage_relationship(:event_type_id, :event_type, type: :append, on_lookup: :relate)
      change manage_relationship(:booth_category_id, :booth_category, type: :append, on_lookup: :relate)
      validate present(:name)
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
      accept [:name]
      argument :booth_category_id, :uuid
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
