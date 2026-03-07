defmodule UniboExPoc.Ofbiz.Product.ProductCategoryRollup do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_category_rollups"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_category_rollup

    queries do
      get :get_product_product_category_rollup, :read
      list :list_product_product_category_rollups, :read
    end

    mutations do
      create :create_product_product_category_rollup, :create
      update :update_product_product_category_rollup, :update
      destroy :delete_product_product_category_rollup, :destroy
    end

  end

  attributes do
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :sequence_num, :integer, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :current_product_category, UniboExPoc.Ofbiz.Product.ProductCategory do
      public? true
      source_attribute :product_category_id
    end
    belongs_to :parent_product_category, UniboExPoc.Ofbiz.Product.ProductCategory do
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
