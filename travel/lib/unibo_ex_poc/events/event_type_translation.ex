defmodule UniboExPoc.Events.EventTypeTranslation do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Events,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "events_event_type_translations"
    repo UniboExPoc.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :locale, :string do
      allow_nil? false
      public? true
    end
    attribute :field_name, :string do
      allow_nil? false
      public? true
    end
    attribute :value, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :event_type, UniboExPoc.Events.EventType do
      public? true
      allow_nil? false
    end
  end

  identities do
    identity :unique_translation, [:event_type_id, :locale, :field_name]
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end
end
