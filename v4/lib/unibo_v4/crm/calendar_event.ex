defmodule UniboV4.CRM.CalendarEvent do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.CRM,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "crm_calendar_events"
    repo UniboV4.Repo
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
    defaults [:read]
  end

end
