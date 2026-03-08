defmodule UniboExPoc.Ofbiz.Order.OrderItemShipGrpInvRes do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_item_ship_grp_inv_reses"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_order_item_ship_grp_inv_res

    queries do
      get :get_order_order_item_ship_grp_inv_res, :read
      list :list_order_order_item_ship_grp_inv_ress, :read
    end

    mutations do
      create :create_order_order_item_ship_grp_inv_res, :create
      update :update_order_order_item_ship_grp_inv_res, :update
      destroy :delete_order_order_item_ship_grp_inv_res, :destroy
    end

  end

  attributes do
    attribute :ship_group_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :order_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :inventory_item_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :reserve_order_enum_id, :string, public?: true
    attribute :quantity, :decimal, public?: true
    attribute :quantity_not_available, :decimal, public?: true
    attribute :reserved_datetime, :utc_datetime, public?: true
    attribute :created_datetime, :utc_datetime, public?: true
    attribute :promised_datetime, :utc_datetime, public?: true
    attribute :current_promised_date, :utc_datetime, public?: true
    attribute :priority, :boolean do
      public? true
      description "设置库存预留的优先级"
    end
    attribute :sequence_id, :integer, public?: true
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
