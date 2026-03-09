# Workflow: training_write_flow — Training 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   start --> [*]
#   complete --> [*]
#   cancel --> [*]
# ```
defmodule UniboExPoc.HR.Training do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "培训记录"
  end

  postgres do
    table "hr_trainings"
    repo UniboExPoc.Repo
  end

  graphql do
    type :hr_training

    queries do
      get :get_hr_training, :read
      list :list_hr_trainings, :read
    end

    mutations do
      create :create_hr_training, :create
      update :start_hr_training, :start
      update :complete_hr_training, :complete
      update :cancel_hr_training, :cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :training_name, :string do
      allow_nil? false
      public? true
      description "培训名称"
    end
    attribute :status, :atom do
      constraints one_of: [:planned, :in_progress, :completed, :cancelled]
      default :planned
      public? true
    end
    attribute :training_type, :atom do
      constraints one_of: [:internal, :external, :online]
      public? true
      description "培训形式"
    end
    attribute :start_date, :date do
      allow_nil? false
      public? true
    end
    attribute :end_date, :date, public?: true
    attribute :score, :decimal do
      public? true
      description "成绩/分数"
    end
    attribute :cost, :decimal do
      public? true
      description "培训费用"
    end
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :employee, UniboExPoc.HR.Employee do
      public? true
      allow_nil? false
    end
    belongs_to :skill, UniboExPoc.HR.Skill do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:training_name, :training_type, :start_date, :end_date, :cost, :notes]
      argument :employee_id, :uuid, allow_nil?: false
      argument :skill_id, :uuid
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      validate present(:training_name)
      change set_attribute(:id, expr(id))
    end
    update :start do
      description "开始培训"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :planned do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :planned}))
        end
      end
      # message: "只有计划中的培训可以开始"
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:status, :in_progress)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :complete do
      description "完成培训，可选填写 score；如关联了 skill_id，自动更新/创建 EmployeeSkill 记录"
      accept [:score]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:planned, :in_progress] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:planned, :in_progress]}))
        end
      end
      # message: "只有计划中或进行中的培训可以完成"
      change set_attribute(:status, :completed)
      change UniboExPoc.HR.Changes.Training.CompleteCall4
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :cancel do
      description "取消培训（不影响已有的 EmployeeSkill）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:planned, :in_progress] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:planned, :in_progress]}))
        end
      end
      # message: "只有计划中或进行中的培训可以取消"
      change set_attribute(:status, :cancelled)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate compare(:end_date, greater_than_or_equal_to: :start_date)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
