defmodule UniboV4.IoT.Media do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.IoT,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "媒体资源占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "io_t_medias"
    repo UniboV4.Repo
  end

  graphql do
    type :io_t_media

    queries do
      get :get_io_t_media, :read
      list :list_io_t_medias, :read
    end

  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      generated? true
      public? true
    end
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
