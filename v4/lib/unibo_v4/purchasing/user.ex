defmodule UniboV4.Purchasing.User do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "purchasing_users"
    repo UniboV4.Repo
  end

  graphql do
    type :purchasing_user

    queries do
      get :get_purchasing_user, :read
      list :list_purchasing_users, :read
      get :get_list_purchasing_user, :list
      list :list_list_purchasing_users, :list
      get :get_search_purchasing_user, :search
      list :list_search_purchasing_users, :search
      get :get_get_purchasing_user, :get
      list :list_get_purchasing_users, :get
      get :get_preview_purchasing_user, :preview
      list :list_preview_purchasing_users, :preview
      get :get_compute_purchasing_user, :compute
      list :list_compute_purchasing_users, :compute
      get :get_lookup_purchasing_user, :lookup
      list :list_lookup_purchasing_users, :lookup
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
