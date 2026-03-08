defmodule UniboExPoc.Blog.Party do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Blog,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "跨域引用 Organization.Party（统一主体）"
  end

  postgres do
    table "blog_parties"
    repo UniboExPoc.Repo
  end

  graphql do
    type :blog_party

    queries do
      get :get_blog_party, :read
      list :list_blog_partys, :read
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
