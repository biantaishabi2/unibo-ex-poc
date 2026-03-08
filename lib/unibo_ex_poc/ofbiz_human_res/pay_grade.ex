defmodule UniboV4.Ofbiz.HumanRes.PayGrade do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.HumanRes,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "human_res_pay_grades"
    repo UniboV4.Repo
  end

  graphql do
    type :human_res_pay_grade

    queries do
      get :get_human_res_pay_grade, :read
      list :list_human_res_pay_grades, :read
    end

    mutations do
      create :create_human_res_pay_grade, :create
      update :update_human_res_pay_grade, :update
      destroy :delete_human_res_pay_grade, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :pay_grade_id, :string, public?: true
    attribute :pay_grade_name, :string, public?: true
    attribute :comments, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
