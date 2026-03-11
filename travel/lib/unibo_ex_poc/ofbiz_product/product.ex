defmodule UniboExPoc.Ofbiz.Product.Product do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_products"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_product_product

    queries do
      get :get_ofbiz_product_product, :read
      list :list_ofbiz_product_products, :read
    end

    mutations do
      create :create_ofbiz_product_product, :create
      update :update_ofbiz_product_product, :update
      destroy :delete_ofbiz_product_product, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_id, :string, public?: true
    attribute :introduction_date, :utc_datetime, public?: true
    attribute :release_date, :utc_datetime, public?: true
    attribute :support_discontinuation_date, :utc_datetime, public?: true
    attribute :sales_discontinuation_date, :utc_datetime, public?: true
    attribute :sales_disc_when_not_avail, :boolean, public?: true
    attribute :internal_name, :string, public?: true
    attribute :brand_name, :string, public?: true
    attribute :comments, :string, public?: true
    attribute :product_name, :string, public?: true
    attribute :description, :string, public?: true
    attribute :long_description, :string, public?: true
    attribute :price_detail_text, :string, public?: true
    attribute :small_image_url, :string, public?: true
    attribute :medium_image_url, :string, public?: true
    attribute :large_image_url, :string, public?: true
    attribute :detail_image_url, :string, public?: true
    attribute :original_image_url, :string, public?: true
    attribute :detail_screen, :string, public?: true
    attribute :inventory_message, :string, public?: true
    attribute :require_inventory, :boolean, public?: true
    attribute :quantity_uom_id, :string, public?: true
    attribute :quantity_included, :decimal do
      public? true
      description "例如一个12盎司苏打水6罐的包装：quantityIncluded=12，quantityUomId=oz，piecesIncluded=6"
    end
    attribute :pieces_included, :integer, public?: true
    attribute :require_amount, :boolean, public?: true
    attribute :fixed_amount, :decimal do
      public? true
      description "用于以固定面额出售的产品，如礼品卡或充值卡"
    end
    attribute :amount_uom_type_id, :string, public?: true
    attribute :weight_uom_id, :string, public?: true
    attribute :shipping_weight, :decimal do
      public? true
      description "产品的运输重量"
    end
    attribute :product_weight, :decimal, public?: true
    attribute :height_uom_id, :string, public?: true
    attribute :product_height, :decimal, public?: true
    attribute :shipping_height, :decimal, public?: true
    attribute :width_uom_id, :string, public?: true
    attribute :product_width, :decimal, public?: true
    attribute :shipping_width, :decimal, public?: true
    attribute :depth_uom_id, :string, public?: true
    attribute :product_depth, :decimal, public?: true
    attribute :shipping_depth, :decimal, public?: true
    attribute :diameter_uom_id, :string, public?: true
    attribute :product_diameter, :decimal, public?: true
    attribute :product_rating, :decimal, public?: true
    attribute :rating_type_enum, :string, public?: true
    attribute :returnable, :boolean, public?: true
    attribute :taxable, :boolean, public?: true
    attribute :charge_shipping, :boolean, public?: true
    attribute :auto_create_keywords, :boolean, public?: true
    attribute :include_in_promotions, :boolean, public?: true
    attribute :is_virtual, :boolean, public?: true
    attribute :is_variant, :boolean, public?: true
    attribute :virtual_variant_method_enum, :string do
      public? true
      description "定义从虚拟产品的可选功能中选择变体的方法。可以是变体爆炸（支持约200个变体）或功能爆炸（几乎无限制）"
    end
    attribute :origin_geo_id, :string, public?: true
    attribute :requirement_method_enum_id, :string, public?: true
    attribute :bill_of_material_level, :integer, public?: true
    attribute :reserv_max_persons, :decimal do
      public? true
      description "同时租赁此资产的最大人数"
    end
    attribute :reserv2nd_pp_perc, :decimal do
      public? true
      description "租赁此资产的第二个人的终端价格百分比"
    end
    attribute :reserv_nth_pp_perc, :decimal do
      public? true
      description "租赁此资产的第N个人的终端价格百分比"
    end
    attribute :config_id, :string do
      public? true
      description "用于保存聚合产品的持久配置ID"
    end
    attribute :created_date, :utc_datetime, public?: true
    attribute :created_by_user_login, :string, public?: true
    attribute :last_modified_date, :utc_datetime, public?: true
    attribute :last_modified_by_user_login, :string, public?: true
    attribute :in_shipping_box, :boolean, public?: true
    attribute :default_shipment_box_type_id, :string, public?: true
    attribute :lot_id_filled_in, :string do
      public? true
      description "指示是否必须填写lotId"
    end
    attribute :order_decimal_quantity, :boolean do
      public? true
      description "用于指示是否可以为此产品订购小数数量。默认值为Y"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_type, UniboExPoc.Ofbiz.Product.ProductType do
      public? true
    end
    belongs_to :primary_product_category, UniboExPoc.Ofbiz.Product.ProductCategory do
      public? true
    end
    belongs_to :facility, UniboExPoc.Ofbiz.Product.Facility do
      public? true
    end
    has_many :product_feature_and_appl, UniboExPoc.Ofbiz.Product.ProductFeatureAppl do
      public? true
    end
    belongs_to :inventory_item_type, UniboExPoc.Ofbiz.Product.InventoryItemType do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
    archive_related [:product_feature_and_appl]
  end

end
