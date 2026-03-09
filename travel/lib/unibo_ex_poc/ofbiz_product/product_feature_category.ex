defmodule UniboExPoc.Ofbiz.Product.ProductFeatureCategory do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_feature_categories"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_product_product_feature_category

    queries do
      get :get_ofbiz_product_product_feature_category, :read
      list :list_ofbiz_product_product_feature_categorys, :read
    end

    mutations do
      create :create_ofbiz_product_product_feature_category, :create
      update :update_ofbiz_product_product_feature_category, :update
      destroy :delete_ofbiz_product_product_feature_category, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_feature_category_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_product_feature_category, UniboExPoc.Ofbiz.Product.ProductFeatureCategory do
      public? true
      source_attribute :parent_category_id
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
