defmodule UniboExPoc.Lunch.LunchOrderTopping3Link do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Lunch,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "订单-配料槽3桥接占位实体"
  end

  postgres do
    table "lunch_order_topping3_links"
    repo UniboExPoc.Repo
  end

  graphql do
    type :lunch_lunch_order_topping3_link

    queries do
      get :get_lunch_lunch_order_topping3_link, :read
      list :list_lunch_lunch_order_topping3_links, :read
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
