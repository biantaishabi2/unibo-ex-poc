defmodule UniboExPoc.Ofbiz.Shipment.PicklistStatus do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "shipment_picklist_statuses"
    repo UniboExPoc.Repo
  end

  graphql do
    type :shipment_picklist_status

    queries do
      get :get_shipment_picklist_status, :read
      list :list_shipment_picklist_statuss, :read
    end

    mutations do
      create :create_shipment_picklist_status, :create
      update :update_shipment_picklist_status, :update
      destroy :delete_shipment_picklist_status, :destroy
    end

  end

  attributes do
    attribute :status_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :picklist, UniboExPoc.Ofbiz.Shipment.Picklist do
      public? true
      attribute_type :string
    end
    belongs_to :change_user_login, UniboExPoc.Ofbiz.Shipment.UserLogin do
      public? true
      source_attribute :change_by_user_login_id
      attribute_type :string
    end
    belongs_to :status_item, UniboExPoc.Ofbiz.Shipment.StatusItem do
      public? true
      source_attribute :status_id
      attribute_type :string
    end
    belongs_to :to_status_item, UniboExPoc.Ofbiz.Shipment.StatusItem do
      public? true
      source_attribute :status_id_to
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
