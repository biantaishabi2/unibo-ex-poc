defmodule UniboV4.Travel.TravelHotel do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Travel,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "酒店主数据（Travel 层，来源 OFBiz Product）"
  end

  postgres do
    table "travel_hotels"
    repo UniboV4.Repo
  end

  graphql do
    type :travel_travel_hotel

    queries do
      get :get_travel_travel_hotel, :read
      list :list_travel_travel_hotels, :read
    end

    mutations do
      create :create_travel_travel_hotel, :create
      update :update_travel_travel_hotel, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :hotel_code, :string do
      allow_nil? false
      public? true
      description "酒店规范编码"
    end
    attribute :hotel_name, :string do
      allow_nil? false
      public? true
      description "酒店名称"
    end
    attribute :city_code, :string do
      public? true
      description "城市编码冗余（便于兼容检索）"
    end
    attribute :hotel_star, :string do
      public? true
      description "酒店星级"
    end
    attribute :status, :atom do
      constraints one_of: [:active, :inactive]
      default :active
      public? true
    end
  end

  relationships do
    belongs_to :city, UniboV4.Ecommerce.TravelCity do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:hotel_code, :hotel_name, :city_id, :city_code, :hotel_star, :status]
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:hotel_name, :city_id, :city_code, :hotel_star, :status]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_hotel_code, [:hotel_code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
