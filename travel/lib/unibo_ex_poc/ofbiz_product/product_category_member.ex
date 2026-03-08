defmodule UniboExPoc.Ofbiz.Product.ProductCategoryMember do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_category_members"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_category_member

    queries do
      get :get_product_product_category_member, :read
      list :list_product_product_category_members, :read
    end

    mutations do
      create :create_product_product_category_member, :create
      update :update_product_product_category_member, :update
      destroy :delete_product_product_category_member, :destroy
    end

  end

  attributes do
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :comments, :string, public?: true
    attribute :sequence_num, :integer, public?: true
    attribute :quantity, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product, UniboExPoc.Ofbiz.Product.Product do
      public? true
    end
    belongs_to :product_category, UniboExPoc.Ofbiz.Product.ProductCategory do
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
