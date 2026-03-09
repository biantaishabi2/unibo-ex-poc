defmodule UniboExPoc.Maintenance.Lot do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "批次占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "maintenance_lots"
    repo UniboExPoc.Repo
  end

  graphql do
    type :maintenance_lot

    queries do
      get :get_maintenance_lot, :read
      list :list_maintenance_lots, :read
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
