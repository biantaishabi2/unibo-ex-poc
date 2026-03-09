# Workflow: resume_line_write_flow — ResumeLine 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.HR.ResumeLine do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "简历条目，记录员工的工作/教育/培训经历"
  end

  postgres do
    table "hr_resume_lines"
    repo UniboExPoc.Repo
  end

  graphql do
    type :hr_resume_line

    queries do
      get :get_hr_resume_line, :read
      list :list_hr_resume_lines, :read
    end

    mutations do
      create :create_hr_resume_line, :create
      update :update_hr_resume_line, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "条目标题（如公司名、学校名）"
    end
    attribute :date_start, :date do
      allow_nil? false
      public? true
      description "开始日期"
    end
    attribute :date_end, :date do
      public? true
      description "结束日期（空表示至今）"
    end
    attribute :description, :string do
      public? true
      description "详细描述"
    end
    attribute :display_type, :atom do
      constraints one_of: [:classic]
      default :classic
      public? true
      description "显示类型"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :employee, UniboExPoc.HR.Employee do
      public? true
      allow_nil? false
    end
    belongs_to :line_type, UniboExPoc.HR.ResumeLineType do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :date_start, :date_end, :description, :display_type]
      argument :employee_id, :uuid, allow_nil?: false
      argument :line_type_id, :uuid
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      validate present(:name)
      validate present(:date_start)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :date_start, :date_end, :description]
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
