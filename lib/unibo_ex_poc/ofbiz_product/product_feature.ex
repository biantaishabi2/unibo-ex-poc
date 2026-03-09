defmodule UniboExPoc.Ofbiz.Product.ProductFeature do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_features"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_feature

    queries do
      get :get_product_product_feature, :read
      list :list_product_product_features, :read
    end

    mutations do
      create :create_product_product_feature, :create
      update :update_product_product_feature, :update
      destroy :delete_product_product_feature, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_feature_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :uom_id, :string, public?: true
    attribute :number_specified, :decimal, public?: true
    attribute :default_amount, :decimal, public?: true
    attribute :default_sequence_num, :integer, public?: true
    attribute :abbrev, :string, public?: true
    attribute :id_code, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_feature_category, UniboExPoc.Ofbiz.Product.ProductFeatureCategory do
      public? true
    end
    belongs_to :product_feature_type, UniboExPoc.Ofbiz.Product.ProductFeatureType do
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
