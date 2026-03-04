defmodule UniboV4.Helpdesk.FieldServiceOrderTagLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "helpdesk_field_service_order_tag_links"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :service_order, UniboV4.Helpdesk.FieldServiceOrder do
      public? true
      allow_nil? false
      source_attribute :field_service_order_id
    end
    belongs_to :tag, UniboV4.Helpdesk.Tag do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
  end

end
