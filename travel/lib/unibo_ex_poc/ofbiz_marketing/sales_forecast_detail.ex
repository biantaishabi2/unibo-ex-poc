defmodule UniboExPoc.Ofbiz.Marketing.SalesForecastDetail do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "marketing_sales_forecast_details"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_sales_forecast_detail

    queries do
      get :get_marketing_sales_forecast_detail, :read
      list :list_marketing_sales_forecast_details, :read
    end

    mutations do
      create :create_marketing_sales_forecast_detail, :create
      update :update_marketing_sales_forecast_detail, :update
      destroy :delete_marketing_sales_forecast_detail, :destroy
    end

  end

  attributes do
    attribute :sales_forecast_detail_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :amount, :decimal, public?: true
    attribute :quantity_uom_id, :string, public?: true
    attribute :quantity, :decimal, public?: true
    attribute :product_id, :string, public?: true
    attribute :product_category_id, :string, public?: true
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
