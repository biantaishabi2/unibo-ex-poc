defmodule UniboV4.CRM.CalendarEvent do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.CRM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "crm_calendar_events"
    repo UniboV4.Repo
  end

  graphql do
    type :crm_calendar_event

    queries do
      get :get_crm_calendar_event, :read
      list :list_crm_calendar_events, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
  end

  relationships do
    belongs_to :lead, UniboV4.CRM.Lead do
      public? true
    end
  end

  actions do
    defaults [:read, :update]
  end

end
