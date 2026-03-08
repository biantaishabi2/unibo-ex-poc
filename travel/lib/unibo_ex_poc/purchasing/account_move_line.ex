defmodule UniboExPoc.Purchasing.AccountMoveLine do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "发票行占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "purchasing_account_move_lines"
    repo UniboExPoc.Repo
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
    belongs_to :move, UniboExPoc.Purchasing.AccountMove do
      public? true
      source_attribute :account_move_id
    end
    belongs_to :purchase_line, UniboExPoc.Purchasing.PurchaseOrderLine do
      public? true
      source_attribute :purchase_order_line_id
    end
  end

  actions do
    defaults [:read, :update]
    read :list do
      description "列表查询"
    end
    read :search do
      description "条件检索"
    end
    read :get do
      description "详情查询"
    end
    read :preview do
      description "预览查询"
    end
    read :compute do
      description "计算查询"
    end
    read :lookup do
      description "快速检索"
    end
  end

end
