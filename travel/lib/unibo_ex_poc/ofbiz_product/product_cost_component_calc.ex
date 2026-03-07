defmodule UniboExPoc.Ofbiz.Product.ProductCostComponentCalc do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_product_cost_component_calcs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_cost_component_calc

    queries do
      get :get_product_product_cost_component_calc, :read
      list :list_product_product_cost_component_calcs, :read
    end

    mutations do
      create :create_product_product_cost_component_calc, :create
      update :update_product_product_cost_component_calc, :update
      destroy :delete_product_product_cost_component_calc, :destroy
    end

  end

  attributes do
    attribute :product_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :cost_component_type_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :sequence_num, :integer, public?: true
    attribute :thru_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product, UniboExPoc.Ofbiz.Product.Product do
      public? true
      define_attribute? false
    end
    belongs_to :cost_component_type, UniboExPoc.Ofbiz.Product.CostComponentType do
      public? true
      define_attribute? false
    end
    belongs_to :cost_component_calc, UniboExPoc.Ofbiz.Product.CostComponentCalc do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
