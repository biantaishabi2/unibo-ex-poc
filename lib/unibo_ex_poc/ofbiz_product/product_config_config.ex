defmodule UniboV4.Ofbiz.Product.ProductConfigConfig do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_config_configs"
    repo UniboV4.Repo
  end

  graphql do
    type :product_product_config_config

    queries do
      get :get_product_product_config_config, :read
      list :list_product_product_config_configs, :read
    end

    mutations do
      create :create_product_product_config_config, :create
      update :update_product_product_config_config, :update
      destroy :delete_product_product_config_config, :destroy
    end

  end

  attributes do
    attribute :config_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :sequence_num, :integer do
      allow_nil? false
      primary_key? true
      generated? true
      public? true
    end
    attribute :config_option_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :config_item_product_config_item, UniboV4.Ofbiz.Product.ProductConfigItem do
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
