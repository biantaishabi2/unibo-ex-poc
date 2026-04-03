defmodule UniboExPoc.Travel.TravelAirline do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Travel,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "航司主数据（Travel 层，来源 OFBiz PartyGroup）"
  end

  postgres do
    table "travel_airlines"
    repo UniboExPoc.Repo
    identity_index_names unique_airline_code: "idx_travel_airlines_unique_airline_code"
  end

  graphql do
    type :travel_travel_airline

    queries do
      get :get_travel_travel_airline, :read
      list :list_travel_travel_airlines, :read
    end

    mutations do
      create :create_travel_travel_airline, :create
      update :update_travel_travel_airline, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :airline_code, :string do
      allow_nil? false
      public? true
      description "航司规范编码"
    end
    attribute :airline_name, :string do
      allow_nil? false
      public? true
      description "航司名称"
    end
    attribute :iata_code, :string do
      public? true
      description "IATA 二字码"
    end
    attribute :icao_code, :string do
      public? true
      description "ICAO 三字码"
    end
    attribute :status, :atom do
      constraints one_of: [:active, :inactive]
      default :active
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Travel Airline via Create. doc_url: graphql://contract/travel/create_travel_travel_airline"
      primary? true
      accept [:airline_code, :airline_name, :iata_code, :icao_code, :status]
    end
    update :update do
      description "Update Travel Airline via Update. doc_url: graphql://contract/travel/update_travel_travel_airline"
      primary? true
      accept [:airline_name, :iata_code, :icao_code, :status]
      require_atomic? false
    end
  end

  identities do
    identity :unique_airline_code, [:airline_code]
  end

end
