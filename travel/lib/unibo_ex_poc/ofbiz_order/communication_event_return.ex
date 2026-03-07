defmodule UniboExPoc.Ofbiz.Order.CommunicationEventReturn do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_communication_event_returns"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_communication_event_return

    queries do
      get :get_order_communication_event_return, :read
      list :list_order_communication_event_returns, :read
    end

    mutations do
      create :create_order_communication_event_return, :create
      update :update_order_communication_event_return, :update
      destroy :delete_order_communication_event_return, :destroy
    end

  end

  attributes do
    attribute :communication_event_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :return_header, UniboExPoc.Ofbiz.Order.ReturnHeader do
      public? true
      source_attribute :return_id
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
