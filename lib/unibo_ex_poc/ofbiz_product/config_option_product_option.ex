defmodule UniboExPoc.Ofbiz.Product.ConfigOptionProductOption do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_config_option_product_options"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_config_option_product_option

    queries do
      get :get_product_config_option_product_option, :read
      list :list_product_config_option_product_options, :read
    end

    mutations do
      create :create_product_config_option_product_option, :create
      update :update_product_config_option_product_option, :update
      destroy :delete_product_config_option_product_option, :destroy
    end

  end

  attributes do
    attribute :config_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :config_item_id, :string do
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
    attribute :product_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :product_option_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
