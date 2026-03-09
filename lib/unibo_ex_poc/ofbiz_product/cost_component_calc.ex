defmodule UniboExPoc.Ofbiz.Product.CostComponentCalc do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_cost_component_calcs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_cost_component_calc

    queries do
      get :get_product_cost_component_calc, :read
      list :list_product_cost_component_calcs, :read
    end

    mutations do
      create :create_product_cost_component_calc, :create
      update :update_product_cost_component_calc, :update
      destroy :delete_product_cost_component_calc, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :cost_component_calc_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :cost_gl_account_type_id, :string, public?: true
    attribute :offsetting_gl_account_type_id, :string, public?: true
    attribute :fixed_cost, :decimal, public?: true
    attribute :variable_cost, :decimal, public?: true
    attribute :per_milli_second, :integer, public?: true
    attribute :currency_uom_id, :string, public?: true
    attribute :cost_custom_method_id, :string, public?: true
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
