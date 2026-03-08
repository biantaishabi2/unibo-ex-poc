defmodule UniboV4.Ofbiz.Order.AllocationPlanHeader do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_allocation_plan_headers"
    repo UniboV4.Repo
  end

  graphql do
    type :order_allocation_plan_header

    queries do
      get :get_order_allocation_plan_header, :read
      list :list_order_allocation_plan_headers, :read
    end

    mutations do
      create :create_order_allocation_plan_header, :create
      update :update_order_allocation_plan_header, :update
      destroy :delete_order_allocation_plan_header, :destroy
    end

  end

  attributes do
    attribute :plan_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :product_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :plan_name, :string, public?: true
    attribute :status_id, :string, public?: true
    attribute :created_by_user_login, :string, public?: true
    attribute :last_modified_by_user_login, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :plan_type_id_allocation_plan_type, UniboV4.Ofbiz.Order.AllocationPlanType do
      public? true
      source_attribute :plan_type_id
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
