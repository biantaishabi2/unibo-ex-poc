defmodule UniboV4.Manufacturing.WorkOrderDependencyLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "manufacturing_work_order_dependency_links"
    repo UniboV4.Repo
  end

  graphql do
    type :manufacturing_work_order_dependency_link

    queries do
      get :get_manufacturing_work_order_dependency_link, :read
      list :list_manufacturing_work_order_dependency_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :blocked_by_workorder, UniboV4.Manufacturing.WorkOrder do
      public? true
      allow_nil? false
    end
    belongs_to :needed_by_workorder, UniboV4.Manufacturing.WorkOrder do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
