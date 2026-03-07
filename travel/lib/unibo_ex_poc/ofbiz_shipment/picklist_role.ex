defmodule UniboExPoc.Ofbiz.Shipment.PicklistRole do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "shipment_picklist_roles"
    repo UniboExPoc.Repo
  end

  graphql do
    type :shipment_picklist_role

    queries do
      get :get_shipment_picklist_role, :read
      list :list_shipment_picklist_roles, :read
    end

    mutations do
      create :create_shipment_picklist_role, :create
      update :update_shipment_picklist_role, :update
      destroy :delete_shipment_picklist_role, :destroy
    end

  end

  attributes do
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :created_by_user_login, :string, public?: true
    attribute :last_modified_by_user_login, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :picklist, UniboExPoc.Ofbiz.Shipment.Picklist do
      public? true
      attribute_type :string
    end
    belongs_to :role_type, UniboExPoc.Ofbiz.Shipment.RoleType do
      public? true
      attribute_type :string
    end
    belongs_to :party_name_view, UniboExPoc.Ofbiz.Shipment.Party do
      public? true
      source_attribute :party_id
      attribute_type :string
    end
    belongs_to :created_by_user_login, UniboExPoc.Ofbiz.Shipment.UserLogin do
      public? true
      source_attribute :created_by_user_login
      define_attribute? false
      attribute_type :string
    end
    belongs_to :last_modified_by_user_login, UniboExPoc.Ofbiz.Shipment.UserLogin do
      public? true
      source_attribute :last_modified_by_user_login
      define_attribute? false
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
