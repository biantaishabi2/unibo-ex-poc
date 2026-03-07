defmodule UniboExPoc.Ecommerce.TravelCity do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "旅行城市主数据（Core 层，来源 OFBiz Geo）"
  end

  postgres do
    table "ecommerce_travel_cities"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ecommerce_travel_city

    queries do
      get :get_ecommerce_travel_city, :read
      list :list_ecommerce_travel_citys, :read
    end

    mutations do
      create :create_ecommerce_travel_city, :create
      update :update_ecommerce_travel_city, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :city_code, :string do
      allow_nil? false
      public? true
      description "城市规范编码（Core 主键语义）"
    end
    attribute :city_name, :string do
      allow_nil? false
      public? true
      description "城市名称"
    end
    attribute :country_code, :string do
      public? true
      description "国家编码"
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

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:city_code, :city_name, :country_code, :geo_id, :status]
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:city_name, :country_code, :geo_id, :status]
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
  end

  identities do
    identity :unique_city_code, [:city_code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
