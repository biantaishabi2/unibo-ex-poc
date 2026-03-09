defmodule UniboExPoc.Ofbiz.Marketing.SalesForecastHistory do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "marketing_sales_forecast_histories"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_sales_forecast_history

    queries do
      get :get_marketing_sales_forecast_history, :read
      list :list_marketing_sales_forecast_historys, :read
    end

    mutations do
      create :create_marketing_sales_forecast_history, :create
      update :update_marketing_sales_forecast_history, :update
      destroy :delete_marketing_sales_forecast_history, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :sales_forecast_history_id, :string, public?: true
    attribute :parent_sales_forecast_id, :string, public?: true
    attribute :organization_party_id, :string, public?: true
    attribute :internal_party_id, :string, public?: true
    attribute :custom_time_period_id, :string, public?: true
    attribute :currency_uom_id, :string, public?: true
    attribute :quota_amount, :decimal, public?: true
    attribute :forecast_amount, :decimal, public?: true
    attribute :best_case_amount, :decimal, public?: true
    attribute :closed_amount, :decimal, public?: true
    attribute :percent_of_quota_forecast, :decimal, public?: true
    attribute :percent_of_quota_closed, :decimal, public?: true
    attribute :change_note, :string do
      public? true
      description "用于追踪此变更的原因"
    end
    attribute :modified_by_user_login_id, :string, public?: true
    attribute :modified_timestamp, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :sales_forecast, UniboExPoc.Ofbiz.Marketing.SalesForecast do
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
