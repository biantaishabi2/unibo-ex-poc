defmodule UniboExPoc.Ofbiz.Order.CustRequestCategory do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "order_cust_request_categories"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_order_cust_request_category

    queries do
      get :get_ofbiz_order_cust_request_category, :read
      list :list_ofbiz_order_cust_request_categorys, :read
    end

    mutations do
      create :create_ofbiz_order_cust_request_category, :create
      update :update_ofbiz_order_cust_request_category, :update
      destroy :delete_ofbiz_order_cust_request_category, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :cust_request_category_id, :string, public?: true
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
