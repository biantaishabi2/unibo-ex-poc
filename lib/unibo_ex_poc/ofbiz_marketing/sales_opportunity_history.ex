defmodule UniboExPoc.Ofbiz.Marketing.SalesOpportunityHistory do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "marketing_sales_opportunity_histories"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_sales_opportunity_history

    queries do
      get :get_marketing_sales_opportunity_history, :read
      list :list_marketing_sales_opportunity_historys, :read
    end

    mutations do
      create :create_marketing_sales_opportunity_history, :create
      update :update_marketing_sales_opportunity_history, :update
      destroy :delete_marketing_sales_opportunity_history, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :sales_opportunity_history_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :next_step, :string, public?: true
    attribute :estimated_amount, :decimal, public?: true
    attribute :estimated_probability, :decimal, public?: true
    attribute :currency_uom_id, :string, public?: true
    attribute :estimated_close_date, :utc_datetime, public?: true
    attribute :change_note, :string do
      public? true
      description "用于追踪此变更的原因"
    end
    attribute :modified_by_user_login, :string, public?: true
    attribute :modified_timestamp, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :sales_opportunity_stage, UniboExPoc.Ofbiz.Marketing.SalesOpportunityStage do
      public? true
      source_attribute :opportunity_stage_id
    end
    belongs_to :sales_opportunity, UniboExPoc.Ofbiz.Marketing.SalesOpportunity do
      public? true
    end
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
