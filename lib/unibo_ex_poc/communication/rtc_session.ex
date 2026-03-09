defmodule UniboExPoc.Communication.RTCSession do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Communication,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "RTC 会话占位实体（用于成员来电邀请关联）"
  end

  postgres do
    table "communication_rtc_sessions"
    repo UniboExPoc.Repo
  end

  graphql do
    type :communication_rtc_session

    queries do
      get :get_communication_rtc_session, :read
      list :list_communication_rtc_sessions, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :state, :string, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
