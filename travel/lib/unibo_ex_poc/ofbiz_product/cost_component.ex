defmodule UniboExPoc.Ofbiz.Product.CostComponent do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_cost_components"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_cost_component

    queries do
      get :get_product_cost_component, :read
      list :list_product_cost_components, :read
    end

    mutations do
      create :create_product_cost_component, :create
      update :update_product_cost_component, :update
      destroy :delete_product_cost_component, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :cost_component_id, :string, public?: true
    attribute :party_id, :string, public?: true
    attribute :geo_id, :string, public?: true
    attribute :work_effort_id, :string, public?: true
    attribute :fixed_asset_id, :string, public?: true
    attribute :from_date, :utc_datetime, public?: true
    attribute :thru_date, :utc_datetime, public?: true
    attribute :cost, :decimal do
      public? true
      description "更高精度，以防是计算的数字"
    end
    attribute :cost_uom_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :cost_component_type, UniboExPoc.Ofbiz.Product.CostComponentType do
      public? true
    end
    belongs_to :product, UniboExPoc.Ofbiz.Product.Product do
      public? true
    end
    belongs_to :product_feature, UniboExPoc.Ofbiz.Product.ProductFeature do
      public? true
    end
    belongs_to :cost_component_calc, UniboExPoc.Ofbiz.Product.CostComponentCalc do
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
