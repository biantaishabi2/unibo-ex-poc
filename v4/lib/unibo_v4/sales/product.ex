defmodule UniboV4.Sales.Product do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Sales,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "sales_products"
    repo UniboV4.Repo
  end

  graphql do
    type :sales_product

    queries do
      get :get_sales_product, :read
      list :list_sales_products, :read
      get :get_list_sales_product, :list
      list :list_list_sales_products, :list
      get :get_search_sales_product, :search
      list :list_search_sales_products, :search
      get :get_get_sales_product, :get
      list :list_get_sales_products, :get
      get :get_preview_sales_product, :preview
      list :list_preview_sales_products, :preview
      get :get_compute_sales_product, :compute
      list :list_compute_sales_products, :compute
      get :get_lookup_sales_product, :lookup
      list :list_lookup_sales_products, :lookup
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_code, :string, public?: true
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read, :update]
    read :list do
    end
    read :search do
    end
    read :get do
    end
    read :preview do
    end
    read :compute do
    end
    read :lookup do
    end
  end

end
