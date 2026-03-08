defmodule UniboExPoc.Quality.WorkOrderOperation do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Quality,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "工序占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "quality_work_order_operations"
    repo UniboExPoc.Repo
  end

  graphql do
    type :quality_work_order_operation

    queries do
      get :get_quality_work_order_operation, :read
      list :list_quality_work_order_operations, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
