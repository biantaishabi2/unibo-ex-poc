defmodule UniboExPoc.Ofbiz.Product.ProductCategoryTypeAttr do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_category_type_attrs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_category_type_attr

    queries do
      get :get_product_product_category_type_attr, :read
      list :list_product_product_category_type_attrs, :read
    end

    mutations do
      create :create_product_product_category_type_attr, :create
      update :update_product_product_category_type_attr, :update
      destroy :delete_product_product_category_type_attr, :destroy
    end

  end

  attributes do
    attribute :attr_name, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_category_type, UniboExPoc.Ofbiz.Product.ProductCategoryType do
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
