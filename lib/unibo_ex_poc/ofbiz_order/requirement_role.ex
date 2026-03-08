defmodule UniboV4.Ofbiz.Order.RequirementRole do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_requirement_roles"
    repo UniboV4.Repo
  end

  graphql do
    type :order_requirement_role

    queries do
      get :get_order_requirement_role, :read
      list :list_order_requirement_roles, :read
    end

    mutations do
      create :create_order_requirement_role, :create
      update :update_order_requirement_role, :update
      destroy :delete_order_requirement_role, :destroy
    end

  end

  attributes do
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
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :requirement, UniboV4.Ofbiz.Order.Requirement do
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
