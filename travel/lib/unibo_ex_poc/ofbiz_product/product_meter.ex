defmodule UniboExPoc.Ofbiz.Product.ProductMeter do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_meters"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_meter

    queries do
      get :get_product_product_meter, :read
      list :list_product_product_meters, :read
    end

    mutations do
      create :create_product_product_meter, :create
      update :update_product_product_meter, :update
      destroy :delete_product_product_meter, :destroy
    end

  end

  attributes do
    attribute :product_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :product_meter_type_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
      description "作为主键的一部分，因为机器上的不同计量器应具有不同的类型"
    end
    attribute :meter_uom_id, :string do
      public? true
      description "在此实体上而不是ProductMeterType实体上，以获得更多灵活性；例如能够查找所有速度计，无论其主要单位如何"
    end
    attribute :meter_name, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product, UniboExPoc.Ofbiz.Product.Product do
      public? true
      define_attribute? false
    end
    belongs_to :product_meter_type, UniboExPoc.Ofbiz.Product.ProductMeterType do
      public? true
      define_attribute? false
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
