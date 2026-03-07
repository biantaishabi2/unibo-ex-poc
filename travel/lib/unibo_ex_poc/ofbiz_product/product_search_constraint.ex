defmodule UniboExPoc.Ofbiz.Product.ProductSearchConstraint do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_search_constraints"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_search_constraint

    queries do
      get :get_product_product_search_constraint, :read
      list :list_product_product_search_constraints, :read
    end

    mutations do
      create :create_product_product_search_constraint, :create
      update :update_product_product_search_constraint, :update
      destroy :delete_product_product_search_constraint, :destroy
    end

  end

  attributes do
    attribute :constraint_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :constraint_name, :string, public?: true
    attribute :info_string, :string, public?: true
    attribute :include_sub_categories, :boolean, public?: true
    attribute :is_and, :boolean, public?: true
    attribute :any_prefix, :boolean, public?: true
    attribute :any_suffix, :boolean, public?: true
    attribute :remove_stems, :boolean, public?: true
    attribute :low_value, :string, public?: true
    attribute :high_value, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_search_result, UniboExPoc.Ofbiz.Product.ProductSearchResult do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
