defmodule UniboExPoc.Ofbiz.Common.CustomTimePeriod do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Custom Time Period"
  end

  postgres do
    table "common_custom_time_periods"
    repo UniboExPoc.Repo
  end

  graphql do
    type :common_custom_time_period

    queries do
      get :get_common_custom_time_period, :read
      list :list_common_custom_time_periods, :read
    end

    mutations do
      create :create_common_custom_time_period, :create
      update :update_common_custom_time_period, :update
      destroy :delete_common_custom_time_period, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :custom_time_period_id, :string, public?: true
    attribute :period_num, :integer, public?: true
    attribute :period_name, :string, public?: true
    attribute :from_date, :utc_datetime, public?: true
    attribute :thru_date, :utc_datetime, public?: true
    attribute :is_closed, :boolean, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_custom_time_period, UniboExPoc.Ofbiz.Common.CustomTimePeriod do
      public? true
      source_attribute :parent_period_id
    end
    belongs_to :period_type, UniboExPoc.Ofbiz.Common.PeriodType do
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
