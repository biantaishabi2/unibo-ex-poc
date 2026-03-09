defmodule UniboExPoc.Ofbiz.Shipment.Picklist do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "shipment_picklists"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_shipment_picklist

    queries do
      get :get_ofbiz_shipment_picklist, :read
      list :list_ofbiz_shipment_picklists, :read
    end

    mutations do
      create :create_ofbiz_shipment_picklist, :create
      update :update_ofbiz_shipment_picklist, :update
      destroy :delete_ofbiz_shipment_picklist, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :picklist_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :picklist_date, :utc_datetime, public?: true
    attribute :created_date, :utc_datetime, public?: true
    attribute :created_by_user_login, :string, public?: true
    attribute :last_modified_date, :utc_datetime, public?: true
    attribute :last_modified_by_user_login, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :facility, UniboExPoc.Ofbiz.Shipment.Facility do
      public? true
      attribute_type :string
    end
    belongs_to :shipment_method_type, UniboExPoc.Ofbiz.Shipment.ShipmentMethodType do
      public? true
      attribute_type :string
    end
    belongs_to :status_item, UniboExPoc.Ofbiz.Shipment.StatusItem do
      public? true
      source_attribute :status_id
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
