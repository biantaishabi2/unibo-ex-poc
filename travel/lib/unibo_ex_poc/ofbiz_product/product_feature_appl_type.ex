defmodule UniboExPoc.Ofbiz.Product.ProductFeatureApplType do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_feature_appl_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_feature_appl_type

    queries do
      get :get_product_product_feature_appl_type, :read
      list :list_product_product_feature_appl_types, :read
    end

    mutations do
      create :create_product_product_feature_appl_type, :create
      update :update_product_product_feature_appl_type, :update
      destroy :delete_product_product_feature_appl_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_feature_appl_type_id, :string, public?: true
    attribute :has_table, :boolean, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_product_feature_appl_type, UniboExPoc.Ofbiz.Product.ProductFeatureApplType do
      public? true
      source_attribute :parent_type_id
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
