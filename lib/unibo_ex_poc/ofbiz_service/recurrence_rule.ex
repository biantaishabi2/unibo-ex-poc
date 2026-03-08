defmodule UniboV4.Ofbiz.Service.RecurrenceRule do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Service,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Recurrence Rule"
  end

  postgres do
    table "service_recurrence_rules"
    repo UniboV4.Repo
  end

  graphql do
    type :service_recurrence_rule

    queries do
      get :get_service_recurrence_rule, :read
      list :list_service_recurrence_rules, :read
    end

    mutations do
      create :create_service_recurrence_rule, :create
      update :update_service_recurrence_rule, :update
      destroy :delete_service_recurrence_rule, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :recurrence_rule_id, :string, public?: true
    attribute :frequency, :string, public?: true
    attribute :until_date_time, :utc_datetime, public?: true
    attribute :count_number, :integer, public?: true
    attribute :interval_number, :integer, public?: true
    attribute :by_second_list, :string, public?: true
    attribute :by_minute_list, :string, public?: true
    attribute :by_hour_list, :string, public?: true
    attribute :by_day_list, :string, public?: true
    attribute :by_month_day_list, :string, public?: true
    attribute :by_year_day_list, :string, public?: true
    attribute :by_week_no_list, :string, public?: true
    attribute :by_month_list, :string, public?: true
    attribute :by_set_pos_list, :string, public?: true
    attribute :week_start, :string, public?: true
    attribute :x_name, :string, public?: true
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
