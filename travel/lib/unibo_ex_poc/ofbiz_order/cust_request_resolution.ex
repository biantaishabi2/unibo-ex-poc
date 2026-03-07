defmodule UniboExPoc.Ofbiz.Order.CustRequestResolution do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "order_cust_request_resolutions"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_cust_request_resolution

    queries do
      get :get_order_cust_request_resolution, :read
      list :list_order_cust_request_resolutions, :read
    end

    mutations do
      create :create_order_cust_request_resolution, :create
      update :update_order_cust_request_resolution, :update
      destroy :delete_order_cust_request_resolution, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :cust_request_resolution_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :cust_request_type, UniboExPoc.Ofbiz.Order.CustRequestType do
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
