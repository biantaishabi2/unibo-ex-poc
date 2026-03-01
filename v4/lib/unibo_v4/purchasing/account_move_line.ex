defmodule UniboV4.Purchasing.AccountMoveLine do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "purchasing_account_move_lines"
    repo UniboV4.Repo
  end

  graphql do
    type :purchasing_account_move_line

    queries do
      get :get_purchasing_account_move_line, :read
      list :list_purchasing_account_move_lines, :read
      get :get_list_purchasing_account_move_line, :list
      list :list_list_purchasing_account_move_lines, :list
      get :get_search_purchasing_account_move_line, :search
      list :list_search_purchasing_account_move_lines, :search
      get :get_get_purchasing_account_move_line, :get
      list :list_get_purchasing_account_move_lines, :get
      get :get_preview_purchasing_account_move_line, :preview
      list :list_preview_purchasing_account_move_lines, :preview
      get :get_compute_purchasing_account_move_line, :compute
      list :list_compute_purchasing_account_move_lines, :compute
      get :get_lookup_purchasing_account_move_line, :lookup
      list :list_lookup_purchasing_account_move_lines, :lookup
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :move, UniboV4.Purchasing.AccountMove do
      public? true
      source_attribute :account_move_id
    end
    belongs_to :purchase_line, UniboV4.Purchasing.PurchaseOrderLine do
      public? true
      source_attribute :purchase_order_line_id
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
