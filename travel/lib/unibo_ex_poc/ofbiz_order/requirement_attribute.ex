defmodule UniboExPoc.Ofbiz.Order.RequirementAttribute do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_requirement_attributes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_requirement_attribute

    queries do
      get :get_order_requirement_attribute, :read
      list :list_order_requirement_attributes, :read
    end

    mutations do
      create :create_order_requirement_attribute, :create
      update :update_order_requirement_attribute, :update
      destroy :delete_order_requirement_attribute, :destroy
    end

  end

  attributes do
    attribute :requirement_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
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
    belongs_to :requirement, UniboExPoc.Ofbiz.Order.Requirement do
      public? true
      define_attribute? false
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
