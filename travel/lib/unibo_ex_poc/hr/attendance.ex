defmodule UniboExPoc.HR.Attendance do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "考勤记录（跨域引用占位，实体定义在 Attendance 域）"
  end

  postgres do
    table "hr_attendances"
    repo UniboExPoc.Repo
  end

  graphql do
    type :hr_attendance

    queries do
      get :get_hr_attendance, :read
      list :list_hr_attendances, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :employee, UniboExPoc.HR.Employee do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
