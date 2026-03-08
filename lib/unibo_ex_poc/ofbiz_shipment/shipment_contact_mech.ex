defmodule UniboV4.Ofbiz.Shipment.ShipmentContactMech do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "shipment_shipment_contact_meches"
    repo UniboV4.Repo
  end

  graphql do
    type :shipment_shipment_contact_mech

    queries do
      get :get_shipment_shipment_contact_mech, :read
      list :list_shipment_shipment_contact_mechs, :read
    end

    mutations do
      create :create_shipment_shipment_contact_mech, :create
      update :update_shipment_shipment_contact_mech, :update
      destroy :delete_shipment_shipment_contact_mech, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :shipment, UniboV4.Ofbiz.Shipment.Shipment do
      public? true
      attribute_type :string
    end
    belongs_to :contact_mech, UniboV4.Ofbiz.Shipment.ContactMech do
      public? true
      attribute_type :string
    end
    belongs_to :shipment_contact_mech_type, UniboV4.Ofbiz.Shipment.ShipmentContactMechType do
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
