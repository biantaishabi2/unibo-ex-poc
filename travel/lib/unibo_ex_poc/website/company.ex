defmodule UniboExPoc.Website.Company do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Website,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "公司占位实体（跨域引用）"
  end

  postgres do
    table "website_companies"
    repo UniboExPoc.Repo
  end

  graphql do
    type :website_company

    queries do
      get :get_website_company, :read
      list :list_website_companys, :read
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
