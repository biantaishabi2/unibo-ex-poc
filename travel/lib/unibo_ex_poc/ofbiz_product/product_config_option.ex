defmodule UniboExPoc.Ofbiz.Product.ProductConfigOption do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_config_options"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_config_option

    queries do
      get :get_product_product_config_option, :read
      list :list_product_product_config_options, :read
    end

    mutations do
      create :create_product_product_config_option, :create
      update :update_product_product_config_option, :update
      destroy :delete_product_product_config_option, :destroy
    end

  end

  attributes do
    attribute :config_option_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :from_date, :utc_datetime, public?: true
    attribute :thru_date, :utc_datetime, public?: true
    attribute :config_option_name, :string, public?: true
    attribute :description, :string, public?: true
    attribute :sequence_num, :integer, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
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
