defmodule UniboExPoc.HR.JourneyTemplate do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "旅程模板，定义入职/离职/调动等标准化流程"
  end

  postgres do
    table "hr_journey_templates"
    repo UniboExPoc.Repo
  end

  graphql do
    type :hr_journey_template

    queries do
      get :get_hr_journey_template, :read
      list :list_hr_journey_templates, :read
    end

    mutations do
      create :create_hr_journey_template, :create
      update :update_hr_journey_template, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "模板名称"
    end
    attribute :journey_type, :atom do
      allow_nil? false
      constraints one_of: [:onboarding, :offboarding, :transfer, :promotion, :return_from_leave]
      public? true
      description "旅程类型"
    end
    attribute :description, :string, public?: true
    attribute :active, :boolean do
      default true
      public? true
      description "是否启用"
    end
    attribute :inserted_at, :utc_datetime_usec do
      allow_nil? false
      writable? false
      default &DateTime.utc_now/0
      public? true
    end
    attribute :updated_at, :utc_datetime_usec do
      allow_nil? false
      writable? false
      default &DateTime.utc_now/0
      update_default &DateTime.utc_now/0
      public? true
    end
  end

  relationships do
    has_many :steps, UniboExPoc.HR.JourneyStep do
      public? true
    end
    has_many :employee_journeys, UniboExPoc.HR.EmployeeJourney do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Journey Template via Create. doc_url: graphql://contract/hr/create_hr_journey_template"
      primary? true
      accept [:name, :journey_type, :description, :active]
      validate present(:name)
    end
    update :update do
      description "Update Journey Template via Update. doc_url: graphql://contract/hr/update_hr_journey_template"
      primary? true
      accept [:name, :description, :active]
    end
  end

end
