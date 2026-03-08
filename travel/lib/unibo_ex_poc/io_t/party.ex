defmodule UniboExPoc.IoT.Party do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.IoT,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "跨域引用 Organization.Party（统一主体）"
  end

  postgres do
    table "io_t_parties"
    repo UniboExPoc.Repo
  end

  graphql do
    type :io_t_party

    queries do
      get :get_io_t_party, :read
      list :list_io_t_partys, :read
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
