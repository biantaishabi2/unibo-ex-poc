defmodule UniboV4.Sales.Tax do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Sales,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "sales_taxes"
    repo UniboV4.Repo
  end

  graphql do
    type :sales_tax

    queries do
      get :get_sales_tax, :read
      list :list_sales_taxs, :read
      get :get_list_sales_tax, :list
      list :list_list_sales_taxs, :list
      get :get_search_sales_tax, :search
      list :list_search_sales_taxs, :search
      get :get_get_sales_tax, :get
      list :list_get_sales_taxs, :get
      get :get_preview_sales_tax, :preview
      list :list_preview_sales_taxs, :preview
      get :get_compute_sales_tax, :compute
      list :list_compute_sales_taxs, :compute
      get :get_lookup_sales_tax, :lookup
      list :list_lookup_sales_taxs, :lookup
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read, :update]
    create :create do
      primary? true
      accept [:name]
    end
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
