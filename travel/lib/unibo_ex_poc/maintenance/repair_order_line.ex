defmodule UniboExPoc.Maintenance.RepairOrderLine do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "维修单零件行占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "maintenance_repair_order_lines"
    repo UniboExPoc.Repo
  end

  graphql do
    type :maintenance_repair_order_line

    queries do
      get :get_maintenance_repair_order_line, :read
      list :list_maintenance_repair_order_lines, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :repair_order, UniboExPoc.Maintenance.RepairOrder do
      public? true
    end
  end

  actions do
    defaults [:read, :update]
  end

end
