defmodule UniboV4.Marketing.EventRegistration do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "event_registrations"
    repo UniboV4.Repo
  end

  graphql do
    type :event_registration

    queries do
      get :get_event_registration, :read
      list :list_event_registrations, :read
    end

    mutations do
      create :create_event_registration, :create
      update :confirm_event_registration, :confirm
      update :cancel_event_registration, :cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :attendee_name, :string, allow_nil?: false, public?: true
    attribute :attendee_email, :string, public?: true
    attribute :status, :atom do
      constraints one_of: [:registered, :confirmed, :attended, :cancelled]
      default :registered
        public? true
    end
    attribute :registration_date, :date, allow_nil?: false, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :event, UniboV4.Marketing.Event do
      allow_nil? false
        public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:attendee_name, :attendee_email, :registration_date]
      argument :event_id, :uuid, allow_nil?: false
      change manage_relationship(:event_id, :event, type: :append, on_lookup: :relate)
      validate present(:attendee_name)
    end
    update :confirm do
      accept []
      change set_attribute(:status, :confirmed)
    end
    update :cancel do
      accept []
      change set_attribute(:status, :cancelled)
    end
  end

end
