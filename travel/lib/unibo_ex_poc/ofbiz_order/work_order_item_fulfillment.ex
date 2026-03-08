defmodule UniboExPoc.Ofbiz.Order.WorkOrderItemFulfillment do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_work_order_item_fulfillments"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_work_order_item_fulfillment

    queries do
      get :get_order_work_order_item_fulfillment, :read
      list :list_order_work_order_item_fulfillments, :read
    end

    mutations do
      create :create_order_work_order_item_fulfillment, :create
      update :update_order_work_order_item_fulfillment, :update
      destroy :delete_order_work_order_item_fulfillment, :destroy
    end

  end

  attributes do
    attribute :work_effort_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :order_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :ship_group_seq_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :order_header, UniboExPoc.Ofbiz.Order.OrderHeader do
      public? true
      source_attribute :order_id
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
