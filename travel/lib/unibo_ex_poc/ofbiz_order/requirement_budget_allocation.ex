defmodule UniboExPoc.Ofbiz.Order.RequirementBudgetAllocation do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_requirement_budget_allocations"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_requirement_budget_allocation

    queries do
      get :get_order_requirement_budget_allocation, :read
      list :list_order_requirement_budget_allocations, :read
    end

    mutations do
      create :create_order_requirement_budget_allocation, :create
      update :update_order_requirement_budget_allocation, :update
      destroy :delete_order_requirement_budget_allocation, :destroy
    end

  end

  attributes do
    attribute :budget_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :budget_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :amount, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :requirement, UniboExPoc.Ofbiz.Order.Requirement do
      public? true
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
