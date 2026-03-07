defmodule UniboExPoc.Ofbiz.Product.ProductConfigStats do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_config_statses"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_config_stats

    queries do
      get :get_product_product_config_stats, :read
      list :list_product_product_config_statss, :read
    end

    mutations do
      create :create_product_product_config_stats, :create
      update :update_product_product_config_stats, :update
      destroy :delete_product_product_config_stats, :destroy
    end

  end

  attributes do
    attribute :config_id, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :num_of_confs, :integer, public?: true
    attribute :config_type_id, :string do
      public? true
      description "例如HIDDEN、TEMPLATE等"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_product, UniboExPoc.Ofbiz.Product.Product do
      public? true
      source_attribute :product_id
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
