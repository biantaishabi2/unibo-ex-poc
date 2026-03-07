defmodule UniboExPoc.Sales.User do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Sales,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "用户占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "sales_users"
    repo UniboExPoc.Repo
  end

  graphql do
    type :sales_user

    queries do
      get :get_sales_user, :read
      list :list_sales_users, :read
      get :get_list_sales_user, :list
      list :list_list_sales_users, :list
      get :get_search_sales_user, :search
      list :list_search_sales_users, :search
      get :get_get_sales_user, :get
      list :list_get_sales_users, :get
      get :get_preview_sales_user, :preview
      list :list_preview_sales_users, :preview
      get :get_compute_sales_user, :compute
      list :list_compute_sales_users, :compute
      get :get_lookup_sales_user, :lookup
      list :list_lookup_sales_users, :lookup
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
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
