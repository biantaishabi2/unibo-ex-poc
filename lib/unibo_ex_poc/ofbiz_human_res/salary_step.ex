defmodule UniboV4.Ofbiz.HumanRes.SalaryStep do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.HumanRes,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "human_res_salary_steps"
    repo UniboV4.Repo
  end

  graphql do
    type :human_res_salary_step

    queries do
      get :get_human_res_salary_step, :read
      list :list_human_res_salary_steps, :read
    end

    mutations do
      create :create_human_res_salary_step, :create
      update :update_human_res_salary_step, :update
      destroy :delete_human_res_salary_step, :destroy
    end

  end

  attributes do
    attribute :salary_step_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :date_modified, :utc_datetime, public?: true
    attribute :amount, :decimal, public?: true
    attribute :created_by_user_login, :string, public?: true
    attribute :last_modified_by_user_login, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :pay_grade, UniboV4.Ofbiz.HumanRes.PayGrade do
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
