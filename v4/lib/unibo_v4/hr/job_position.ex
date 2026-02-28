defmodule UniboV4.HR.JobPosition do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "job_positions"
    repo UniboV4.Repo
  end

  graphql do
    type :job_position

    queries do
      get :get_job_position, :read
      list :list_job_positions, :read
    end

    mutations do
      create :create_job_position, :create
      update :update_job_position, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :position_code, :string, allow_nil?: false
    attribute :title, :string, allow_nil?: false
    attribute :headcount, :integer, default: 1
    attribute :is_active, :boolean, default: true
    attribute :description, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :department, UniboV4.HR.Department
    belongs_to :pay_grade, UniboV4.HR.PayGrade
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:position_code, :title, :headcount, :description]
      argument :department_id, :uuid
      validate present(:position_code)
      validate present(:title)
    end
    update :update do
      primary? true
      accept [:title, :headcount, :is_active, :description]
    end
  end

  identities do
    identity :unique_position_code, [:position_code]
  end

end
