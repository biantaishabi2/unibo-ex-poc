defmodule UniboV4.Ofbiz.Shipment.ShipmentMethodType do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "shipment_method_types"
    repo UniboV4.Repo
  end

  graphql do
    type :shipment_shipment_method_type

    queries do
      get :get_shipment_shipment_method_type, :read
      list :list_shipment_shipment_method_types, :read
    end

    mutations do
      create :create_shipment_shipment_method_type, :create
      update :update_shipment_shipment_method_type, :update
      destroy :delete_shipment_shipment_method_type, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :shipment_method_type_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :sequence_num, :integer, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
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
