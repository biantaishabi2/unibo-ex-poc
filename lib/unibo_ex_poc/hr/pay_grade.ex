# Workflow: pay_grade_write_flow — PayGrade 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.HR.PayGrade do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "薪资等级"
  end

  postgres do
    table "hr_pay_grades"
    repo UniboV4.Repo
  end

  graphql do
    type :hr_pay_grade

    queries do
      get :get_hr_pay_grade, :read
      list :list_hr_pay_grades, :read
    end

    mutations do
      create :create_hr_pay_grade, :create
      update :update_hr_pay_grade, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :grade_code, :string do
      allow_nil? false
      public? true
      description "等级编号"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :min_salary, :decimal do
      public? true
      description "最低薪资"
    end
    attribute :max_salary, :decimal do
      public? true
      description "最高薪资"
    end
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:grade_code, :name, :min_salary, :max_salary, :description]
      validate present(:grade_code)
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :min_salary, :max_salary, :description]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_grade_code, [:grade_code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
