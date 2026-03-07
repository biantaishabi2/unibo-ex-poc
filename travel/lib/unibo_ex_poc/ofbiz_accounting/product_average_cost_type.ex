defmodule UniboExPoc.Ofbiz.Accounting.ProductAverageCostType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_product_average_cost_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_product_average_cost_type

    queries do
      get :get_accounting_product_average_cost_type, :read
      list :list_accounting_product_average_cost_types, :read
    end

    mutations do
      create :create_accounting_product_average_cost_type, :create
      update :update_accounting_product_average_cost_type, :update
      destroy :delete_accounting_product_average_cost_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_average_cost_type_id, :string, public?: true
    attribute :has_table, :boolean, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_product_average_cost_type, UniboExPoc.Ofbiz.Accounting.ProductAverageCostType do
      public? true
      source_attribute :parent_type_id
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
