defmodule UniboExPoc.Ofbiz.Shipment.ShipmentTypeAttr do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "shipment_type_attrs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :shipment_shipment_type_attr

    queries do
      get :get_shipment_shipment_type_attr, :read
      list :list_shipment_shipment_type_attrs, :read
    end

    mutations do
      create :create_shipment_shipment_type_attr, :create
      update :update_shipment_shipment_type_attr, :update
      destroy :delete_shipment_shipment_type_attr, :destroy
    end

  end

  attributes do
    attribute :attr_name, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :shipment_type, UniboExPoc.Ofbiz.Shipment.ShipmentType do
      public? true
      attribute_type :string
    end
    has_many :shipment, UniboExPoc.Ofbiz.Shipment.Shipment do
      public? true
      destination_attribute :shipment_type_id
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
    archive_related [:shipment]
  end

end
