defmodule UniboExPoc.Ofbiz.Product.ProductSearchResult do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_search_results"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_search_result

    queries do
      get :get_product_product_search_result, :read
      list :list_product_product_search_results, :read
    end

    mutations do
      create :create_product_product_search_result, :create
      update :update_product_product_search_result, :update
      destroy :delete_product_product_search_result, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_search_result_id, :string, public?: true
    attribute :visit_id, :string, public?: true
    attribute :order_by_name, :string, public?: true
    attribute :is_ascending, :boolean, public?: true
    attribute :num_results, :integer, public?: true
    attribute :seconds_total, :float, public?: true
    attribute :search_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
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
