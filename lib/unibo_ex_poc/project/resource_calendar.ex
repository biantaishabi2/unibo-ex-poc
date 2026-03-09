defmodule UniboExPoc.Project.ResourceCalendar do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "资源日历占位实体（工作时长计算上下文）"
  end

  postgres do
    table "project_resource_calendars"
    repo UniboExPoc.Repo
  end

  graphql do
    type :project_resource_calendar

    queries do
      get :get_project_resource_calendar, :read
      list :list_project_resource_calendars, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
