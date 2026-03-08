defmodule UniboV4.Ofbiz.HumanRes.PerfReview do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.HumanRes,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "human_res_perf_reviews"
    repo UniboV4.Repo
  end

  graphql do
    type :human_res_perf_review

    queries do
      get :get_human_res_perf_review, :read
      list :list_human_res_perf_reviews, :read
    end

    mutations do
      create :create_human_res_perf_review, :create
      update :update_human_res_perf_review, :update
      destroy :delete_human_res_perf_review, :destroy
    end

  end

  attributes do
    attribute :employee_role_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :perf_review_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :manager_role_type_id, :string, public?: true
    attribute :from_date, :utc_datetime, public?: true
    attribute :thru_date, :utc_datetime, public?: true
    attribute :comments, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :employee_party, UniboV4.Ofbiz.HumanRes.Party do
      public? true
      attribute_type :string
    end
    belongs_to :manager_party, UniboV4.Ofbiz.HumanRes.Party do
      public? true
      attribute_type :string
    end
    belongs_to :payment, UniboV4.Ofbiz.HumanRes.Payment do
      public? true
      attribute_type :string
    end
    belongs_to :empl_position, UniboV4.Ofbiz.HumanRes.EmplPosition do
      public? true
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
