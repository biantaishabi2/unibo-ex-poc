defmodule UniboExPoc.Ofbiz.Order.OrderItemShipGroup do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "order_item_ship_groups"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_order_item_ship_group

    queries do
      get :get_order_order_item_ship_group, :read
      list :list_order_order_item_ship_groups, :read
    end

    mutations do
      create :create_order_order_item_ship_group, :create
      update :update_order_order_item_ship_group, :update
      destroy :delete_order_order_item_ship_group, :destroy
    end

  end

  attributes do
    attribute :ship_group_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :shipment_method_type_id, :string, public?: true
    attribute :supplier_party_id, :string, public?: true
    attribute :supplier_agreement_id, :string, public?: true
    attribute :vendor_party_id, :string do
      public? true
      description "用于多供应商商店，订单将被分割以使每个配送组仅与一个供应商关联（仅如适用）"
    end
    attribute :carrier_party_id, :string, public?: true
    attribute :carrier_role_type_id, :string, public?: true
    attribute :facility_id, :string, public?: true
    attribute :contact_mech_id, :string, public?: true
    attribute :telecom_contact_mech_id, :string, public?: true
    attribute :tracking_number, :string, public?: true
    attribute :shipping_instructions, :string, public?: true
    attribute :may_split, :boolean, public?: true
    attribute :gift_message, :string, public?: true
    attribute :is_gift, :boolean, public?: true
    attribute :ship_after_date, :utc_datetime, public?: true
    attribute :ship_by_date, :utc_datetime, public?: true
    attribute :estimated_ship_date, :utc_datetime, public?: true
    attribute :estimated_delivery_date, :utc_datetime, public?: true
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
