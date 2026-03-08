defmodule UniboExPoc.Helpdesk.HelpdeskStage do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "工单阶段占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "helpdesk_stages"
    repo UniboExPoc.Repo
  end

  graphql do
    type :helpdesk_helpdesk_stage

    queries do
      get :get_helpdesk_helpdesk_stage, :read
      list :list_helpdesk_helpdesk_stages, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
    attribute :sequence, :integer, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
