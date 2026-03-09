defmodule UniboExPoc.Events.Facility do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Events,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "场馆设施占位实体（活动 venue 引用）"
  end

  postgres do
    table "events_facilities"
    repo UniboExPoc.Repo
  end

  graphql do
    type :events_facility

    queries do
      get :get_events_facility, :read
      list :list_events_facilitys, :read
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
