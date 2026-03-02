defmodule UniboV4.HR.PayGrade do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "pay_grades"
    repo UniboV4.Repo
  end

  graphql do
    type :pay_grade

    queries do
      get :get_pay_grade, :read
      list :list_pay_grades, :read
    end

    mutations do
      create :create_pay_grade, :create
      update :update_pay_grade, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :grade_code, :string, allow_nil?: false, public?: true
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :min_salary, :decimal, public?: true
    attribute :max_salary, :decimal, public?: true
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
    end
    update :update do
      primary? true
      accept [:name, :min_salary, :max_salary, :description]
    end
  end

  identities do
    identity :unique_grade_code, [:grade_code]
  end

end
