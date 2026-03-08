defmodule UniboV4.Ofbiz.Product.ProdConfItemContent do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_prod_conf_item_contents"
    repo UniboV4.Repo
  end

  graphql do
    type :product_prod_conf_item_content

    queries do
      get :get_product_prod_conf_item_content, :read
      list :list_product_prod_conf_item_contents, :read
    end

    mutations do
      create :create_product_prod_conf_item_content, :create
      update :update_product_prod_conf_item_content, :update
      destroy :delete_product_prod_conf_item_content, :destroy
    end

  end

  attributes do
    attribute :content_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_config_item, UniboV4.Ofbiz.Product.ProductConfigItem do
      public? true
      source_attribute :config_item_id
    end
    belongs_to :prod_conf_item_content_type, UniboV4.Ofbiz.Product.ProdConfItemContentType do
      public? true
      source_attribute :conf_item_content_type_id
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
