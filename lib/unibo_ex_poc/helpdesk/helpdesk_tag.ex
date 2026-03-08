defmodule UniboV4.Helpdesk.HelpdeskTag do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "工单标签占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "helpdesk_helpdesk_tags"
    repo UniboV4.Repo
  end

  graphql do
    type :helpdesk_helpdesk_tag

    queries do
      get :get_helpdesk_helpdesk_tag, :read
      list :list_helpdesk_helpdesk_tags, :read
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
