defmodule UniboExPoc.Ofbiz.Product.InventoryItemStatus do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_inventory_item_statuses"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_inventory_item_status

    queries do
      get :get_product_inventory_item_status, :read
      list :list_product_inventory_item_statuss, :read
    end

    mutations do
      create :create_product_inventory_item_status, :create
      update :update_product_inventory_item_status, :update
      destroy :delete_product_inventory_item_status, :destroy
    end

  end

  attributes do
    attribute :status_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :status_datetime, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :status_end_datetime, :utc_datetime, public?: true
    attribute :change_by_user_login_id, :string, public?: true
    attribute :owner_party_id, :string do
      public? true
      description "用于跟踪当状态改变时更改的所有者党派ID"
    end
    attribute :product_id, :string do
      public? true
      description "用于跟踪当状态改变时更改的产品ID。换句话说，随着时间推移，项目可能由不同的产品表示（如新产品与翻新产品）"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :inventory_item, UniboExPoc.Ofbiz.Product.InventoryItem do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
