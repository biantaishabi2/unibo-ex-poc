defmodule UniboExPoc.Studio.Party do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Studio,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "跨域引用 Organization.Party（统一主体）"
  end

  postgres do
    table "studio_parties"
    repo UniboExPoc.Repo
  end

  graphql do
    type :studio_party

    queries do
      get :get_studio_party, :read
      list :list_studio_partys, :read
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
