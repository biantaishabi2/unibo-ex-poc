defmodule UniboExPoc.HR.AttendanceOvertime do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "加班日汇总（跨域引用占位，实体定义在 Attendance 域）"
  end

  postgres do
    table "hr_attendance_overtimes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :hr_attendance_overtime

    queries do
      get :get_hr_attendance_overtime, :read
      list :list_hr_attendance_overtimes, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  actions do
    defaults [:read, :update]
  end

end
