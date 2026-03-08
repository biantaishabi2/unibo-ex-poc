defmodule UniboV4.Ofbiz.Shipment.ShipmentReceiptRole do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "shipment_receipt_roles"
    repo UniboV4.Repo
  end

  graphql do
    type :shipment_shipment_receipt_role

    queries do
      get :get_shipment_shipment_receipt_role, :read
      list :list_shipment_shipment_receipt_roles, :read
    end

    mutations do
      create :create_shipment_shipment_receipt_role, :create
      update :update_shipment_shipment_receipt_role, :update
      destroy :delete_shipment_shipment_receipt_role, :destroy
    end

  end

  attributes do
    attribute :role_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :shipment_receipt, UniboV4.Ofbiz.Shipment.ShipmentReceipt do
      public? true
      source_attribute :receipt_id
      attribute_type :string
    end
    belongs_to :party, UniboV4.Ofbiz.Shipment.Party do
      public? true
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
