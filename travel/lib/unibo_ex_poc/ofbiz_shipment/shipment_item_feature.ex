defmodule UniboExPoc.Ofbiz.Shipment.ShipmentItemFeature do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "shipment_item_features"
    repo UniboExPoc.Repo
  end

  graphql do
    type :shipment_shipment_item_feature

    queries do
      get :get_shipment_shipment_item_feature, :read
      list :list_shipment_shipment_item_features, :read
    end

    mutations do
      create :create_shipment_shipment_item_feature, :create
      update :update_shipment_shipment_item_feature, :update
      destroy :delete_shipment_shipment_item_feature, :destroy
    end

  end

  attributes do
    attribute :shipment_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :shipment, UniboExPoc.Ofbiz.Shipment.Shipment do
      public? true
      attribute_type :string
    end
    belongs_to :product_feature, UniboExPoc.Ofbiz.Shipment.ProductFeature do
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
