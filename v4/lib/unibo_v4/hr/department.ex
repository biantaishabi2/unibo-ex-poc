defmodule UniboV4.HR.Department do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "departments"
    repo UniboV4.Repo
  end

  graphql do
    type :department

    queries do
      get :get_department, :read
      list :list_departments, :read
    end

    mutations do
      create :create_department, :create
      update :update_department, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :department_code, :string, allow_nil?: false, public?: true
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :description, :string, public?: true
    attribute :is_active, :boolean, default: true, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :employees, UniboV4.HR.Employee
    belongs_to :parent, UniboV4.HR.Department, public?: true
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:department_code, :name, :description]
      argument :parent_id, :uuid
      validate present(:department_code)
      validate present(:name)
    end
    update :update do
      primary? true
      accept [:name, :description, :is_active]
    end
  end

  identities do
    identity :unique_department_code, [:department_code]
  end

end
