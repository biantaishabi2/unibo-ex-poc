defmodule UniboExPoc.Ofbiz.Order.Requirement do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_requirements"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_order_requirement

    queries do
      get :get_ofbiz_order_requirement, :read
      list :list_ofbiz_order_requirements, :read
    end

    mutations do
      create :create_ofbiz_order_requirement, :create
      update :update_ofbiz_order_requirement, :update
      destroy :delete_ofbiz_order_requirement, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :requirement_id, :string, public?: true
    attribute :facility_id, :string, public?: true
    attribute :deliverable_id, :string, public?: true
    attribute :fixed_asset_id, :string, public?: true
    attribute :product_id, :string, public?: true
    attribute :status_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :requirement_start_date, :utc_datetime, public?: true
    attribute :required_by_date, :utc_datetime, public?: true
    attribute :estimated_budget, :decimal, public?: true
    attribute :quantity, :decimal, public?: true
    attribute :use_case, :string, public?: true
    attribute :reason, :string, public?: true
    attribute :created_date, :utc_datetime, public?: true
    attribute :created_by_user_login, :string, public?: true
    attribute :last_modified_date, :utc_datetime, public?: true
    attribute :last_modified_by_user_login, :string, public?: true
    attribute :facility_id_to, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :requirement_type, UniboExPoc.Ofbiz.Order.RequirementType do
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
