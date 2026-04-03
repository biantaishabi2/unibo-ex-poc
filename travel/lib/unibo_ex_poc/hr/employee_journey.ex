defmodule UniboExPoc.HR.EmployeeJourney do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshStateMachine]

  resource do
    description "员工旅程实例，跟踪员工在特定旅程中的进度"
  end

  postgres do
    table "hr_employee_journeys"
    repo UniboExPoc.Repo
  end

  graphql do
    type :hr_employee_journey

    queries do
      get :get_hr_employee_journey, :read
      list :list_hr_employee_journeys, :read
    end

    mutations do
      create :create_hr_employee_journey, :create
      update :complete_hr_employee_journey, :complete
      update :cancel_hr_employee_journey, :cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :triggered_date, :date do
      allow_nil? false
      public? true
      description "旅程触发日期"
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:cancelled, :completed, :in_progress]
      default :in_progress
      public? true
    end
    attribute :completed_steps, :integer do
      default 0
      public? true
      description "已完成步骤数"
    end
    attribute :total_steps, :integer do
      public? true
      description "总步骤数"
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
    belongs_to :employee, UniboExPoc.HR.Employee do
      public? true
    end
    belongs_to :journey_template, UniboExPoc.HR.JourneyTemplate do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Employee Journey via Create. doc_url: graphql://contract/hr/create_hr_employee_journey"
      primary? true
      accept [:employee_id, :journey_template_id, :triggered_date, :total_steps]
      validate present(:triggered_date)
    end
    update :complete do
      description "标记旅程完成

标记旅程完成. doc_url: graphql://contract/hr/complete_hr_employee_journey"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :in_progress do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :in_progress}))
        end
      end
      # message: "只有进行中的旅程可以操作"
      change set_attribute(:status, :completed)
      change AshStateMachine.BuiltinChanges.transition_state(:completed)
      require_atomic? false
    end
    update :cancel do
      description "取消旅程

取消旅程. doc_url: graphql://contract/hr/cancel_hr_employee_journey"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :in_progress do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :in_progress}))
        end
      end
      # message: "只有进行中的旅程可以操作"
      change set_attribute(:status, :cancelled)
      change AshStateMachine.BuiltinChanges.transition_state(:cancelled)
      require_atomic? false
    end
  end


  state_machine do
    initial_states [:in_progress]
    default_initial_state :in_progress
    extra_states [:cancelled, :completed, :in_progress]
    state_attribute :status
    transitions do
      transition :complete, from: :in_progress, to: :completed
      transition :cancel, from: :in_progress, to: :cancelled
    end
  end
end
