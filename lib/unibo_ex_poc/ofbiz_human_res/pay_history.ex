defmodule UniboExPoc.Ofbiz.HumanRes.PayHistory do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.HumanRes,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "human_res_pay_histories"
    repo UniboExPoc.Repo
  end

  graphql do
    type :human_res_pay_history

    queries do
      get :get_human_res_pay_history, :read
      list :list_human_res_pay_historys, :read
    end

    mutations do
      create :create_human_res_pay_history, :create
      update :update_human_res_pay_history, :update
      destroy :delete_human_res_pay_history, :destroy
    end

  end

  attributes do
    attribute :role_type_id_from, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :role_type_id_to, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :party_id_from, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :party_id_to, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :empl_from_date, :utc_datetime do
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
    attribute :salary_step_seq_id, :string, public?: true
    attribute :amount, :decimal, public?: true
    attribute :comments, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :pay_grade, UniboExPoc.Ofbiz.HumanRes.PayGrade do
      public? true
      attribute_type :string
    end
    belongs_to :period_type, UniboExPoc.Ofbiz.HumanRes.PeriodType do
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
