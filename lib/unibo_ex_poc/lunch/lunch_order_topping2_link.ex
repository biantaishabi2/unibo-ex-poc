defmodule UniboExPoc.Lunch.LunchOrderTopping2Link do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Lunch,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "订单-配料槽2桥接占位实体"
  end

  postgres do
    table "lunch_order_topping2_links"
    repo UniboExPoc.Repo
  end

  graphql do
    type :lunch_lunch_order_topping2_link

    queries do
      get :get_lunch_lunch_order_topping2_link, :read
      list :list_lunch_lunch_order_topping2_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :lunch_order, UniboExPoc.Lunch.LunchOrder do
      public? true
      allow_nil? false
    end
    belongs_to :topping, UniboExPoc.Lunch.LunchTopping do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
