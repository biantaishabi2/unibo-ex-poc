defmodule UniboExPoc.Ofbiz.Product.ProductCategory do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_categories"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_category

    queries do
      get :get_product_product_category, :read
      list :list_product_product_categorys, :read
    end

    mutations do
      create :create_product_product_category, :create
      update :update_product_product_category, :update
      destroy :delete_product_product_category, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_category_id, :string, public?: true
    attribute :category_name, :string, public?: true
    attribute :description, :string, public?: true
    attribute :long_description, :string, public?: true
    attribute :category_image_url, :string, public?: true
    attribute :link_one_image_url, :string, public?: true
    attribute :link_two_image_url, :string, public?: true
    attribute :detail_screen, :string, public?: true
    attribute :show_in_select, :boolean, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_category_type, UniboExPoc.Ofbiz.Product.ProductCategoryType do
      public? true
    end
    belongs_to :primary_parent_product_category, UniboExPoc.Ofbiz.Product.ProductCategory do
      public? true
      source_attribute :primary_parent_category_id
    end
    has_many :primary_child_product_category, UniboExPoc.Ofbiz.Product.ProductCategory do
      public? true
      source_attribute :primary_parent_category_id
      destination_attribute :primary_parent_category_id
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
    archive_related [:primary_child_product_category]
  end

end
