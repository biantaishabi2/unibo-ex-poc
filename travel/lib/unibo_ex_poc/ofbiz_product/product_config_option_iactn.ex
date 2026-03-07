defmodule UniboExPoc.Ofbiz.Product.ProductConfigOptionIactn do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_config_option_iactns"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_config_option_iactn

    queries do
      get :get_product_product_config_option_iactn, :read
      list :list_product_product_config_option_iactns, :read
    end

    mutations do
      create :create_product_product_config_option_iactn, :create
      update :update_product_product_config_option_iactn, :update
      destroy :delete_product_product_config_option_iactn, :destroy
    end

  end

  attributes do
    attribute :config_option_id, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :config_option_id_to, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :sequence_num, :integer do
      allow_nil? false
      primary_key? true
      allow_nil? false
      generated? true
      public? true
    end
    attribute :config_iactn_type_id, :string do
      public? true
      description "例如INCOMPATIBLE等"
    end
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :config_item_product_config_item, UniboExPoc.Ofbiz.Product.ProductConfigItem do
      public? true
      source_attribute :config_item_id
    end
    belongs_to :config_item_to_product_config_item, UniboExPoc.Ofbiz.Product.ProductConfigItem do
      public? true
      source_attribute :config_item_id_to
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
