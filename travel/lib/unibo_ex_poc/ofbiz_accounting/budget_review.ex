defmodule UniboExPoc.Ofbiz.Accounting.BudgetReview do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_budget_reviews"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_budget_review

    queries do
      get :get_accounting_budget_review, :read
      list :list_accounting_budget_reviews, :read
    end

    mutations do
      create :create_accounting_budget_review, :create
      update :update_accounting_budget_review, :update
      destroy :delete_accounting_budget_review, :destroy
    end

  end

  attributes do
    attribute :budget_review_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :review_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :budget, UniboExPoc.Ofbiz.Accounting.Budget do
      public? true
    end
    belongs_to :budget_review_result_type, UniboExPoc.Ofbiz.Accounting.BudgetReviewResultType do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
