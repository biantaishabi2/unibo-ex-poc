defmodule UniboExPoc.Ofbiz.Product.ProductFeatureDataResource do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_feature_data_resources"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_feature_data_resource

    queries do
      get :get_product_product_feature_data_resource, :read
      list :list_product_product_feature_data_resources, :read
    end

    mutations do
      create :create_product_product_feature_data_resource, :create
      update :update_product_product_feature_data_resource, :update
      destroy :delete_product_product_feature_data_resource, :destroy
    end

  end

  attributes do
    attribute :data_resource_id, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_feature, UniboExPoc.Ofbiz.Product.ProductFeature do
      public? true
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
