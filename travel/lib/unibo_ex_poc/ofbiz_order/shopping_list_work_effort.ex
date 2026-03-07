defmodule UniboExPoc.Ofbiz.Order.ShoppingListWorkEffort do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_shopping_list_work_efforts"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_shopping_list_work_effort

    queries do
      get :get_order_shopping_list_work_effort, :read
      list :list_order_shopping_list_work_efforts, :read
    end

    mutations do
      create :create_order_shopping_list_work_effort, :create
      update :update_order_shopping_list_work_effort, :update
      destroy :delete_order_shopping_list_work_effort, :destroy
    end

  end

  attributes do
    attribute :work_effort_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :shopping_list, UniboExPoc.Ofbiz.Order.ShoppingList do
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
