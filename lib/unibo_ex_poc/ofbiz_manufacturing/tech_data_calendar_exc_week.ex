defmodule UniboV4.Ofbiz.Manufacturing.TechDataCalendarExcWeek do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "用于定义与日历中定义的常规周不同的某些周。"
  end

  postgres do
    table "manufacturing_tech_data_calendar_exc_weeks"
    repo UniboV4.Repo
  end

  graphql do
    type :manufacturing_tech_data_calendar_exc_week

    queries do
      get :get_manufacturing_tech_data_calendar_exc_week, :read
      list :list_manufacturing_tech_data_calendar_exc_weeks, :read
    end

    mutations do
      create :create_manufacturing_tech_data_calendar_exc_week, :create
      update :update_manufacturing_tech_data_calendar_exc_week, :update
      destroy :delete_manufacturing_tech_data_calendar_exc_week, :destroy
    end

  end

  attributes do
    attribute :exception_date_start, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
      description "异常日期开始"
    end
    attribute :description, :string do
      public? true
      description "说明"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :tech_data_calendar, UniboV4.Ofbiz.Manufacturing.TechDataCalendar do
      public? true
      source_attribute :calendar_id
    end
    belongs_to :tech_data_calendar_week, UniboV4.Ofbiz.Manufacturing.TechDataCalendarWeek do
      public? true
      source_attribute :calendar_week_id
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
