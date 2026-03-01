defmodule UniboV4.Purchasing.AccountMove do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "purchasing_account_moves"
    repo UniboV4.Repo
  end

  graphql do
    type :purchasing_account_move

    queries do
      get :get_purchasing_account_move, :read
      list :list_purchasing_account_moves, :read
      get :get_list_purchasing_account_move, :list
      list :list_list_purchasing_account_moves, :list
      get :get_search_purchasing_account_move, :search
      list :list_search_purchasing_account_moves, :search
      get :get_get_purchasing_account_move, :get
      list :list_get_purchasing_account_moves, :get
      get :get_preview_purchasing_account_move, :preview
      list :list_preview_purchasing_account_moves, :preview
      get :get_compute_purchasing_account_move, :compute
      list :list_compute_purchasing_account_moves, :compute
      get :get_lookup_purchasing_account_move, :lookup
      list :list_lookup_purchasing_account_moves, :lookup
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :purchase_order, UniboV4.Purchasing.PurchaseOrder do
      public? true
    end
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
