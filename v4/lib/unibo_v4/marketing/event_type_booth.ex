# Workflow: event_type_booth_maintain_flow — 展位类型维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.Marketing.EventTypeBooth do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "marketing_event_type_booths"
    repo UniboV4.Repo
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
    end
    attribute :event_type_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :booth_category_id, :uuid do
      allow_nil? false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :booth_category, UniboV4.Marketing.EventBoothCategory do
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

end
