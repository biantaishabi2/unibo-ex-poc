defmodule UniboExPoc.Ofbiz.Product.ProductReview do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_reviews"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_review

    queries do
      get :get_product_product_review, :read
      list :list_product_product_reviews, :read
    end

    mutations do
      create :create_product_product_review, :create
      update :update_product_product_review, :update
      destroy :delete_product_product_review, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_review_id, :string, public?: true
    attribute :user_login_id, :string, public?: true
    attribute :status_id, :string, public?: true
    attribute :posted_anonymous, :boolean, public?: true
    attribute :posted_date_time, :utc_datetime, public?: true
    attribute :product_rating, :decimal, public?: true
    attribute :product_review, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_store, UniboExPoc.Ofbiz.Product.ProductStore do
      public? true
    end
    belongs_to :product, UniboExPoc.Ofbiz.Product.Product do
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
