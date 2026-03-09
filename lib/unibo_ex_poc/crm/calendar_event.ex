defmodule UniboExPoc.CRM.CalendarEvent do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.CRM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "日历事件占位实体"
  end

  postgres do
    table "crm_calendar_events"
    repo UniboExPoc.Repo
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
    belongs_to :lead, UniboExPoc.CRM.Lead do
      public? true
    end
  end

  actions do
    defaults [:read, :update]
  end

end
