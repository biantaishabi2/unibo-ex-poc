defmodule UniboV4.Helpdesk.FieldServiceOrderTagLink do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "现场服务单-标签桥接占位实体"
  end

  postgres do
    table "helpdesk_field_service_order_tag_links"
    repo UniboV4.Repo
  end

  graphql do
    type :helpdesk_field_service_order_tag_link

    queries do
      get :get_helpdesk_field_service_order_tag_link, :read
      list :list_helpdesk_field_service_order_tag_links, :read
    end

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
    defaults [:read, :update]
  end

end
