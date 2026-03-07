defmodule UniboExPoc.Ofbiz.Product.CostComponentAttribute do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_cost_component_attributes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_cost_component_attribute

    queries do
      get :get_product_cost_component_attribute, :read
      list :list_product_cost_component_attributes, :read
    end

    mutations do
      create :create_product_cost_component_attribute, :create
      update :update_product_cost_component_attribute, :update
      destroy :delete_product_cost_component_attribute, :destroy
    end

  end

  attributes do
    attribute :attr_name, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :attr_value, :string, public?: true
    attribute :attr_description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :cost_component, UniboExPoc.Ofbiz.Product.CostComponent do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
