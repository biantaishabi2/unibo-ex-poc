defmodule UniboExPoc.Ofbiz.Manufacturing.TechDataCalendar do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "用于定义机器的可用性，此实体定义 ID 和周定义。
      该 ID 在异常日历表中用作参考"
  end

  postgres do
    table "manufacturing_tech_data_calendars"
    repo UniboExPoc.Repo
  end

  graphql do
    type :manufacturing_tech_data_calendar

    queries do
      get :get_manufacturing_tech_data_calendar, :read
      list :list_manufacturing_tech_data_calendars, :read
    end

    mutations do
      create :create_manufacturing_tech_data_calendar, :create
      update :update_manufacturing_tech_data_calendar, :update
      destroy :delete_manufacturing_tech_data_calendar, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :calendar_id, :string do
      public? true
      description "日历编号"
    end
    attribute :description, :string do
      public? true
      description "说明"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :tech_data_calendar_week, UniboExPoc.Ofbiz.Manufacturing.TechDataCalendarWeek do
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
