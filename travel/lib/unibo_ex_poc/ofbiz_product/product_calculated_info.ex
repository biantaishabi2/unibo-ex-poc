defmodule UniboExPoc.Ofbiz.Product.ProductCalculatedInfo do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_calculated_infos"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_calculated_info

    queries do
      get :get_product_product_calculated_info, :read
      list :list_product_product_calculated_infos, :read
    end

    mutations do
      create :create_product_product_calculated_info, :create
      update :update_product_product_calculated_info, :update
      destroy :delete_product_product_calculated_info, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :total_quantity_ordered, :decimal, public?: true
    attribute :total_times_viewed, :integer, public?: true
    attribute :average_customer_rating, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
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
