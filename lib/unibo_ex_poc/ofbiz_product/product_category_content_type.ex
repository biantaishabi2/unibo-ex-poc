defmodule UniboExPoc.Ofbiz.Product.ProductCategoryContentType do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_category_content_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_category_content_type

    queries do
      get :get_product_product_category_content_type, :read
      list :list_product_product_category_content_types, :read
    end

    mutations do
      create :create_product_product_category_content_type, :create
      update :update_product_product_category_content_type, :update
      destroy :delete_product_product_category_content_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :prod_cat_content_type_id, :string, public?: true
    attribute :has_table, :boolean, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_product_category_content_type, UniboExPoc.Ofbiz.Product.ProductCategoryContentType do
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
