defmodule UniboExPoc.Ofbiz.Product.ProductFacility do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_facilities"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_facility

    queries do
      get :get_product_product_facility, :read
      list :list_product_product_facilitys, :read
    end

    mutations do
      create :create_product_product_facility, :create
      update :update_product_product_facility, :update
      destroy :delete_product_product_facility, :destroy
    end

  end

  attributes do
    attribute :minimum_stock, :decimal, public?: true
    attribute :reorder_quantity, :decimal, public?: true
    attribute :days_to_ship, :integer, public?: true
    attribute :replenish_method_enum_id, :string, public?: true
    attribute :last_inventory_count, :decimal do
      public? true
      description "此字段表示产品在某个时间点的可用承诺总额，并由定时任务服务每小时定期更新"
    end
    attribute :requirement_method_enum_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product, UniboExPoc.Ofbiz.Product.Product do
      public? true
    end
    belongs_to :facility, UniboExPoc.Ofbiz.Product.Facility do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
