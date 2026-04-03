defmodule UniboExPoc.HR.JourneyStep do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "旅程步骤，定义单个任务节点"
  end

  postgres do
    table "hr_journey_steps"
    repo UniboExPoc.Repo
  end

  graphql do
    type :hr_journey_step

    queries do
      get :get_hr_journey_step, :read
      list :list_hr_journey_steps, :read
    end

    mutations do
      create :create_hr_journey_step, :create
      update :update_hr_journey_step, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "步骤名称"
    end
    attribute :description, :string, public?: true
    attribute :responsible_role, :atom do
      allow_nil? false
      constraints one_of: [:hr, :manager, :employee, :it, :finance]
      public? true
      description "负责角色"
    end
    attribute :due_days, :integer do
      allow_nil? false
      public? true
      description "触发后N天内完成"
    end
    attribute :sequence, :integer do
      default 0
      public? true
      description "排序序号"
    end
    attribute :mandatory, :boolean do
      default true
      public? true
      description "是否必须完成"
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
    belongs_to :journey_template, UniboExPoc.HR.JourneyTemplate do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Journey Step via Create. doc_url: graphql://contract/hr/create_hr_journey_step"
      primary? true
      accept [:journey_template_id, :name, :description, :responsible_role, :due_days, :sequence, :mandatory]
      validate present(:name)
      validate present(:due_days)
    end
    update :update do
      description "Update Journey Step via Update. doc_url: graphql://contract/hr/update_hr_journey_step"
      primary? true
      accept [:name, :description, :responsible_role, :due_days, :sequence, :mandatory]
    end
  end

end
