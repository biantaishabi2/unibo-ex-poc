defmodule UniboExPoc.Ecommerce.TravelAirport do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "机场主数据（Core 层，来源 OFBiz Geo）"
  end

  postgres do
    table "ecommerce_travel_airports"
    repo UniboExPoc.Repo
    identity_index_names unique_airport_code: "idx_ecommerce_travel_airports_unique_airport_code"
  end

  graphql do
    type :ecommerce_travel_airport

    queries do
      get :get_ecommerce_travel_airport, :read
      list :list_ecommerce_travel_airports, :read
    end

    mutations do
      create :create_ecommerce_travel_airport, :create
      update :update_ecommerce_travel_airport, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :airport_code, :string do
      allow_nil? false
      public? true
      description "机场规范编码"
    end
    attribute :airport_name, :string do
      allow_nil? false
      public? true
      description "机场名称"
    end
    attribute :city_code, :string do
      public? true
      description "城市编码冗余（便于兼容检索）"
    end
    attribute :iata_code, :string do
      public? true
      description "IATA 三字码"
    end
    attribute :icao_code, :string do
      public? true
      description "ICAO 四字码"
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
      description "Create Travel Airport via Create. doc_url: graphql://contract/ecommerce/create_ecommerce_travel_airport"
      primary? true
      accept [:airport_code, :airport_name, :city_id, :city_code, :iata_code, :icao_code, :geo_id, :status]
    end
    update :update do
      description "Update Travel Airport via Update. doc_url: graphql://contract/ecommerce/update_ecommerce_travel_airport"
      primary? true
      accept [:airport_name, :city_id, :city_code, :iata_code, :icao_code, :geo_id, :status]
      require_atomic? false
    end
  end

  identities do
    identity :unique_airport_code, [:airport_code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
