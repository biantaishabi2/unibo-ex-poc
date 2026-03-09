# Workflow: work_entry_validation_flow — 工时条目校验流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   action_validate --> [*]
# ```
# Workflow: work_entry_cancel_flow — 工时条目取消流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   action_cancel --> [*]
# ```
defmodule UniboExPoc.HR.WorkEntry do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.HR.WorkEntry.Notifier]

  resource do
    description "工时条目，记录员工每日实际工时"
  end

  postgres do
    table "hr_work_entries"
    repo UniboExPoc.Repo
  end

  graphql do
    type :hr_work_entry

    queries do
      get :get_hr_work_entry, :read
      list :list_hr_work_entrys, :read
    end

    mutations do
      create :create_hr_work_entry, :create
      update :action_validate_hr_work_entry, :action_validate
      update :action_cancel_hr_work_entry, :action_cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      public? true
      description "条目名称（可自动生成：类型+员工）"
    end
    attribute :is_active, :boolean do
      default true
      public? true
    end
    attribute :date_start, :utc_datetime do
      allow_nil? false
      public? true
      description "工时开始时间"
    end
    attribute :date_stop, :utc_datetime do
      public? true
      description "工时结束时间"
    end
    attribute :duration, :decimal do
      public? true
      description "时长（小时）"
    end
    attribute :state, :atom do
      constraints one_of: [:draft, :validated, :conflict, :cancelled]
      default :draft
      public? true
      description "状态"
    end
    attribute :conflict, :boolean do
      default false
      public? true
      description "是否存在时间重叠冲突"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :employee, UniboExPoc.HR.Employee do
      public? true
      allow_nil? false
    end
    belongs_to :work_entry_type, UniboExPoc.HR.WorkEntryType do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :date_start, :date_stop, :duration]
      argument :employee_id, :uuid, allow_nil?: false
      argument :work_entry_type_id, :uuid
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      validate present(:date_start)
      change UniboExPoc.HR.Changes.WorkEntry.CreateCall3
      change set_attribute(:id, expr(id))
    end
    update :action_validate do
      description "验证工时条目，冲突检测后设置 state=validated"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以验证"
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:state, :validated)
      change UniboExPoc.HR.Changes.WorkEntry.ActionValidateCall3
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_cancel do
      description "取消工时条目"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current in [:draft, :conflict] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must be one of %{values}", vars: %{values: [:draft, :conflict]}))
        end
      end
      # message: "只有草稿或冲突状态可以取消"
      change set_attribute(:state, :cancelled)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
