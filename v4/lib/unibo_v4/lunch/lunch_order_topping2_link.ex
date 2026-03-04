defmodule UniboV4.Lunch.LunchOrderTopping2Link do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Lunch,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "lunch_order_topping2_links"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :lunch_order, UniboV4.Lunch.LunchOrder do
      public? true
      allow_nil? false
    end
    belongs_to :topping, UniboV4.Lunch.LunchTopping do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
  end

end
