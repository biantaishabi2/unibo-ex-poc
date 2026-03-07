defmodule UniboExPoc.Ofbiz.Order.OrderItemRole do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_item_roles"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_order_item_role

    queries do
      get :get_order_order_item_role, :read
      list :list_order_order_item_roles, :read
    end

    mutations do
      create :create_order_order_item_role, :create
      update :update_order_order_item_role, :update
      destroy :delete_order_order_item_role, :destroy
    end

  end

  attributes do
    attribute :order_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :role_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :order_header, UniboExPoc.Ofbiz.Order.OrderHeader do
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
