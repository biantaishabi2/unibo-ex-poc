defmodule UniboV4.Ofbiz.Manufacturing.TechDataCalendarExcDay do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "用于定义与日历中关联的周内的常规日期定义不同的某些天。"
  end

  postgres do
    table "manufacturing_tech_data_calendar_exc_days"
    repo UniboV4.Repo
  end

  graphql do
    type :manufacturing_tech_data_calendar_exc_day

    queries do
      get :get_manufacturing_tech_data_calendar_exc_day, :read
      list :list_manufacturing_tech_data_calendar_exc_days, :read
    end

    mutations do
      create :create_manufacturing_tech_data_calendar_exc_day, :create
      update :update_manufacturing_tech_data_calendar_exc_day, :update
      destroy :delete_manufacturing_tech_data_calendar_exc_day, :destroy
    end

  end

  attributes do
    attribute :exception_date_start_time, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
      description "异常日期开始时间"
    end
    attribute :exception_capacity, :decimal do
      public? true
      description "异常容量"
    end
    attribute :used_capacity, :decimal do
      public? true
      description "已用容量"
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
