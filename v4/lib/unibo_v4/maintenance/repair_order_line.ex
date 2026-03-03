defmodule UniboV4.Maintenance.RepairOrderLine do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "maintenance_repair_order_lines"
    repo UniboV4.Repo
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
    belongs_to :repair_order, UniboV4.Maintenance.RepairOrder do
      public? true
    end
  end

  actions do
    defaults [:read, :update]
  end

end
