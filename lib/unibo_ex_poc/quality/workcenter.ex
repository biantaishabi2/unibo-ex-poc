defmodule UniboExPoc.Quality.Workcenter do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Quality,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "工作中心占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "quality_workcenters"
    repo UniboExPoc.Repo
  end

  graphql do
    type :quality_workcenter

    queries do
      get :get_quality_workcenter, :read
      list :list_quality_workcenters, :read
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
