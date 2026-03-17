defmodule UniboExPoc.Ofbiz.Product.Facility do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_facilities"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_product_facility

    queries do
      get :get_ofbiz_product_facility, :read
      list :list_ofbiz_product_facilitys, :read
    end

    mutations do
      create :create_ofbiz_product_facility, :create
      update :update_ofbiz_product_facility, :update
      destroy :delete_ofbiz_product_facility, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :facility_id, :string, public?: true
    attribute :owner_party_id, :string, public?: true
    attribute :facility_name, :string, public?: true
    attribute :facility_size, :decimal, public?: true
    attribute :facility_size_uom_id, :string, public?: true
    attribute :default_days_to_ship, :integer do
      public? true
      description "在缺少产品特定的发货天数时使用此值作为默认值"
    end
    attribute :opened_date, :utc_datetime, public?: true
    attribute :closed_date, :utc_datetime, public?: true
    attribute :description, :string, public?: true
    attribute :default_dimension_uom_id, :string do
      public? true
      description "此字段存储维度（长、宽、高）的测量单位"
    end
    attribute :default_weight_uom_id, :string, public?: true
    attribute :geo_point_id, :string, public?: true
    attribute :facility_level, :integer do
      public? true
      description "定义设施的级别"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :facility_type, UniboExPoc.Ofbiz.Product.FacilityType do
      public? true
    end
    belongs_to :parent_facility, UniboExPoc.Ofbiz.Product.Facility do
      public? true
    end
    belongs_to :facility_group, UniboExPoc.Ofbiz.Product.FacilityGroup do
      public? true
      source_attribute :primary_facility_group_id
    end
    belongs_to :default_inventory_item_type, UniboExPoc.Ofbiz.Product.InventoryItemType do
      public? true
    end
    belongs_to :product_store, UniboExPoc.Ofbiz.Product.ProductStore do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
