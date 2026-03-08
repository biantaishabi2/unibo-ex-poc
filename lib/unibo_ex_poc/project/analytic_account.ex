defmodule UniboV4.Project.AnalyticAccount do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "分析账户占位实体（project.analytic_account_id 引用）"
  end

  postgres do
    table "project_analytic_accounts"
    repo UniboV4.Repo
  end

  graphql do
    type :project_analytic_account

    queries do
      get :get_project_analytic_account, :read
      list :list_project_analytic_accounts, :read
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
