defmodule UniboExPoc.Inventory.RemovalStrategy do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "出库策略占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "inventory_removal_strategies"
    repo UniboExPoc.Repo
  end

  graphql do
    type :inventory_removal_strategy

    queries do
      get :get_inventory_removal_strategy, :read
      list :list_inventory_removal_strategys, :read
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
