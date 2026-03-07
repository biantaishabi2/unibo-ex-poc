defmodule UniboExPoc.Ofbiz.Product.ProductGroupOrder do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_group_orders"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_group_order

    queries do
      get :get_product_product_group_order, :read
      list :list_product_product_group_orders, :read
    end

    mutations do
      create :create_product_product_group_order, :create
      update :update_product_product_group_order, :update
      destroy :delete_product_product_group_order, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :group_order_id, :string, public?: true
    attribute :from_date, :utc_datetime, public?: true
    attribute :thru_date, :utc_datetime, public?: true
    attribute :status_id, :string, public?: true
    attribute :req_order_qty, :decimal, public?: true
    attribute :sold_order_qty, :decimal, public?: true
    attribute :job_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product, UniboExPoc.Ofbiz.Product.Product do
      public? true
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
