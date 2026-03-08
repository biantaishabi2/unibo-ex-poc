defmodule UniboV4.Ofbiz.Manufacturing.TechDataCalendarWeek do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "用于定义机器的周定义可用性"
  end

  postgres do
    table "manufacturing_tech_data_calendar_weeks"
    repo UniboV4.Repo
  end

  graphql do
    type :manufacturing_tech_data_calendar_week

    queries do
      get :get_manufacturing_tech_data_calendar_week, :read
      list :list_manufacturing_tech_data_calendar_weeks, :read
    end

    mutations do
      create :create_manufacturing_tech_data_calendar_week, :create
      update :update_manufacturing_tech_data_calendar_week, :update
      destroy :delete_manufacturing_tech_data_calendar_week, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :calendar_week_id, :string do
      public? true
      description "日历周编号"
    end
    attribute :description, :string do
      public? true
      description "说明"
    end
    attribute :monday_start_time, :string do
      public? true
      description "周一开始时间"
    end
    attribute :monday_capacity, :float do
      public? true
      description "周一容量"
    end
    attribute :tuesday_start_time, :string do
      public? true
      description "周二开始时间"
    end
    attribute :tuesday_capacity, :float do
      public? true
      description "周二容量"
    end
    attribute :wednesday_start_time, :string do
      public? true
      description "周三开始时间"
    end
    attribute :wednesday_capacity, :float do
      public? true
      description "周三容量"
    end
    attribute :thursday_start_time, :string do
      public? true
      description "周四开始时间"
    end
    attribute :thursday_capacity, :float do
      public? true
      description "周四容量"
    end
    attribute :friday_start_time, :string do
      public? true
      description "周五开始时间"
    end
    attribute :friday_capacity, :float do
      public? true
      description "周五容量"
    end
    attribute :saturday_start_time, :string do
      public? true
      description "周六开始时间"
    end
    attribute :saturday_capacity, :float do
      public? true
      description "周六容量"
    end
    attribute :sunday_start_time, :string do
      public? true
      description "周日开始时间"
    end
    attribute :sunday_capacity, :float do
      public? true
      description "周日容量"
    end
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
