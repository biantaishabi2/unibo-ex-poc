defmodule UniboExPoc.Ofbiz.Order.CustRequestItem do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "order_cust_request_items"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_cust_request_item

    queries do
      get :get_order_cust_request_item, :read
      list :list_order_cust_request_items, :read
    end

    mutations do
      create :create_order_cust_request_item, :create
      update :update_order_cust_request_item, :update
      destroy :delete_order_cust_request_item, :destroy
    end

  end

  attributes do
    attribute :cust_request_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :status_id, :string, public?: true
    attribute :priority, :integer, public?: true
    attribute :sequence_num, :integer, public?: true
    attribute :required_by_date, :utc_datetime, public?: true
    attribute :product_id, :string, public?: true
    attribute :quantity, :decimal, public?: true
    attribute :selected_amount, :decimal, public?: true
    attribute :maximum_amount, :decimal, public?: true
    attribute :reserv_start, :utc_datetime, public?: true
    attribute :reserv_length, :decimal, public?: true
    attribute :reserv_persons, :decimal, public?: true
    attribute :config_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :story, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :cust_request, UniboExPoc.Ofbiz.Order.CustRequest do
      public? true
      attribute_type :string
    end
    belongs_to :cust_request_resolution, UniboExPoc.Ofbiz.Order.CustRequestResolution do
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
