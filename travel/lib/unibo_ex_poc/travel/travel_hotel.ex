defmodule UniboExPoc.Travel.TravelHotel do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Travel,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "酒店主数据（Travel 层，来源 OFBiz Product）"
  end

  postgres do
    table "travel_hotels"
    repo UniboExPoc.Repo
    identity_index_names unique_hotel_code: "idx_travel_hotels_unique_hotel_code"
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
    attribute :city_id, :string, public?: true
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Travel Hotel via Create. doc_url: graphql://contract/travel/create_travel_travel_hotel"
      primary? true
      accept [:hotel_code, :hotel_name, :city_id, :city_code, :hotel_star, :status]
    end
    update :update do
      description "Update Travel Hotel via Update. doc_url: graphql://contract/travel/update_travel_travel_hotel"
      primary? true
      accept [:hotel_name, :city_id, :city_code, :hotel_star, :status]
      require_atomic? false
    end
  end

  identities do
    identity :unique_hotel_code, [:hotel_code]
  end

end
