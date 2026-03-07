defmodule UniboExPoc.Ofbiz.Order.AllocationPlanItem do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_allocation_plan_items"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_allocation_plan_item

    queries do
      get :get_order_allocation_plan_item, :read
      list :list_order_allocation_plan_items, :read
    end

    mutations do
      create :create_order_allocation_plan_item, :create
      update :update_order_allocation_plan_item, :update
      destroy :delete_order_allocation_plan_item, :destroy
    end

  end

  attributes do
    attribute :plan_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :plan_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :status_id, :string, public?: true
    attribute :plan_method_enum_id, :string, public?: true
    attribute :order_item_seq_id, :string, public?: true
    attribute :product_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :allocated_quantity, :decimal, public?: true
    attribute :priority_seq_id, :string, public?: true
    attribute :created_by_user_login, :string, public?: true
    attribute :last_modified_by_user_login, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :order_id_order_header, UniboExPoc.Ofbiz.Order.OrderHeader do
      public? true
      source_attribute :order_id
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
