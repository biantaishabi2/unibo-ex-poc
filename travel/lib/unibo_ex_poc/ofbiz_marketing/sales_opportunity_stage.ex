defmodule UniboExPoc.Ofbiz.Marketing.SalesOpportunityStage do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "marketing_sales_opportunity_stages"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_sales_opportunity_stage

    queries do
      get :get_marketing_sales_opportunity_stage, :read
      list :list_marketing_sales_opportunity_stages, :read
    end

    mutations do
      create :create_marketing_sales_opportunity_stage, :create
      update :update_marketing_sales_opportunity_stage, :update
      destroy :delete_marketing_sales_opportunity_stage, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :opportunity_stage_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :default_probability, :decimal, public?: true
    attribute :sequence_num, :integer, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
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
