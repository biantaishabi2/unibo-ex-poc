defmodule UniboExPoc.Ecommerce.TravelStation do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "火车站主数据（Core 层，来源 OFBiz Geo）"
  end

  postgres do
    table "ecommerce_travel_stations"
    repo UniboExPoc.Repo
    identity_index_names unique_station_code: "idx_ecommerce_travel_stations_unique_station_code"
  end

  graphql do
    type :ecommerce_travel_station

    queries do
      get :get_ecommerce_travel_station, :read
      list :list_ecommerce_travel_stations, :read
    end

    mutations do
      create :create_ecommerce_travel_station, :create
      update :update_ecommerce_travel_station, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :station_code, :string do
      allow_nil? false
      public? true
      description "车站规范编码"
    end
    attribute :station_name, :string do
      allow_nil? false
      public? true
      description "车站名称"
    end
    attribute :city_code, :string do
      public? true
      description "城市编码冗余（便于兼容检索）"
    end
    attribute :geo_id, :string do
      public? true
      description "OFBiz Geo 主键映射"
    end
    attribute :status, :atom do
      constraints one_of: [:active, :inactive]
      default :active
      public? true
    end
  end

  relationships do
    belongs_to :city, UniboExPoc.Ecommerce.TravelCity do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Travel Station via Create. doc_url: graphql://contract/ecommerce/create_ecommerce_travel_station"
      primary? true
      accept [:station_code, :station_name, :city_id, :city_code, :geo_id, :status]
    end
    update :update do
      description "Update Travel Station via Update. doc_url: graphql://contract/ecommerce/update_ecommerce_travel_station"
      primary? true
      accept [:station_name, :city_id, :city_code, :geo_id, :status]
      require_atomic? false
    end
  end

  identities do
    identity :unique_station_code, [:station_code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
