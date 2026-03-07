defmodule UniboExPoc.Ofbiz.Product.ProductConfigProduct do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_config_products"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_config_product

    queries do
      get :get_product_product_config_product, :read
      list :list_product_product_config_products, :read
    end

    mutations do
      create :create_product_product_config_product, :create
      update :update_product_product_config_product, :update
      destroy :delete_product_product_config_product, :destroy
    end

  end

  attributes do
    attribute :config_item_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :config_option_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :product_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :quantity, :decimal, public?: true
    attribute :sequence_num, :integer, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :config_item_product_config_item, UniboExPoc.Ofbiz.Product.ProductConfigItem do
      public? true
      source_attribute :config_item_id
      define_attribute? false
    end
    belongs_to :product_product, UniboExPoc.Ofbiz.Product.Product do
      public? true
      source_attribute :product_id
      define_attribute? false
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
