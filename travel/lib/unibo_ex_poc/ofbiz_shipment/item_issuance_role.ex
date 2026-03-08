defmodule UniboExPoc.Ofbiz.Shipment.ItemIssuanceRole do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "shipment_item_issuance_roles"
    repo UniboExPoc.Repo
  end

  graphql do
    type :shipment_item_issuance_role

    queries do
      get :get_shipment_item_issuance_role, :read
      list :list_shipment_item_issuance_roles, :read
    end

    mutations do
      create :create_shipment_item_issuance_role, :create
      update :update_shipment_item_issuance_role, :update
      destroy :delete_shipment_item_issuance_role, :destroy
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
    belongs_to :item_issuance, UniboExPoc.Ofbiz.Shipment.ItemIssuance do
      public? true
      attribute_type :string
    end
    belongs_to :party, UniboExPoc.Ofbiz.Shipment.Party do
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
