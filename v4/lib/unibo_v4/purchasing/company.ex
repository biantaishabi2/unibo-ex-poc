defmodule UniboV4.Purchasing.Company do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "purchasing_companies"
    repo UniboV4.Repo
  end

  graphql do
    type :purchasing_company

    queries do
      get :get_purchasing_company, :read
      list :list_purchasing_companys, :read
      get :get_list_purchasing_company, :list
      list :list_list_purchasing_companys, :list
      get :get_search_purchasing_company, :search
      list :list_search_purchasing_companys, :search
      get :get_get_purchasing_company, :get
      list :list_get_purchasing_companys, :get
      get :get_preview_purchasing_company, :preview
      list :list_preview_purchasing_companys, :preview
      get :get_compute_purchasing_company, :compute
      list :list_compute_purchasing_companys, :compute
      get :get_lookup_purchasing_company, :lookup
      list :list_lookup_purchasing_companys, :lookup
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :po_lock, :string, public?: true
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
