defmodule UniboV4.Purchasing.Product do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "purchasing_products"
    repo UniboV4.Repo
  end

  graphql do
    type :purchasing_product

    queries do
      get :get_purchasing_product, :read
      list :list_purchasing_products, :read
      get :get_list_purchasing_product, :list
      list :list_list_purchasing_products, :list
      get :get_search_purchasing_product, :search
      list :list_search_purchasing_products, :search
      get :get_get_purchasing_product, :get
      list :list_get_purchasing_products, :get
      get :get_preview_purchasing_product, :preview
      list :list_preview_purchasing_products, :preview
      get :get_compute_purchasing_product, :compute
      list :list_compute_purchasing_products, :compute
      get :get_lookup_purchasing_product, :lookup
      list :list_lookup_purchasing_products, :lookup
    end

  end

  attributes do
    uuid_primary_key :id
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
