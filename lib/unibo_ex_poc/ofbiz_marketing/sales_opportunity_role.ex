defmodule UniboExPoc.Ofbiz.Marketing.SalesOpportunityRole do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "marketing_sales_opportunity_roles"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_sales_opportunity_role

    queries do
      get :get_marketing_sales_opportunity_role, :read
      list :list_marketing_sales_opportunity_roles, :read
    end

    mutations do
      create :create_marketing_sales_opportunity_role, :create
      update :update_marketing_sales_opportunity_role, :update
      destroy :delete_marketing_sales_opportunity_role, :destroy
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
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :sales_opportunity, UniboExPoc.Ofbiz.Marketing.SalesOpportunity do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
