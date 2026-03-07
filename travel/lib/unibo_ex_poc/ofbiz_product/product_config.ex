defmodule UniboExPoc.Ofbiz.Product.ProductConfig do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_configs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_config

    queries do
      get :get_product_product_config, :read
      list :list_product_product_configs, :read
    end

    mutations do
      create :create_product_product_config, :create
      update :update_product_product_config, :update
      destroy :delete_product_product_config, :destroy
    end

  end

  attributes do
    attribute :sequence_num, :integer do
      allow_nil? false
      primary_key? true
      generated? true
      public? true
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :description, :string, public?: true
    attribute :long_description, :string, public?: true
    attribute :config_type_id, :string, public?: true
    attribute :default_config_option_id, :string, public?: true
    attribute :thru_date, :utc_datetime, public?: true
    attribute :is_mandatory, :boolean, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_product, UniboExPoc.Ofbiz.Product.Product do
      public? true
      source_attribute :product_id
    end
    belongs_to :config_item_product_config_item, UniboExPoc.Ofbiz.Product.ProductConfigItem do
      public? true
      source_attribute :config_item_id
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
