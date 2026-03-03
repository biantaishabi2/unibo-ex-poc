defmodule UniboV4.Approvals.Company do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Approvals,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "approvals_companies"
    repo UniboV4.Repo
  end

  graphql do
    type :approvals_company

    queries do
      get :get_approvals_company, :read
      list :list_approvals_companys, :read
    end

  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
