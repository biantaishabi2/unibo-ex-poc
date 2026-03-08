# Workflow: resume_line_type_write_flow — ResumeLineType 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.HR.ResumeLineType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "简历条目类型（如\"工作经历\"、\"教育经历\"、\"培训经历\"）"
  end

  postgres do
    table "hr_resume_line_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :hr_resume_line_type

    queries do
      get :get_hr_resume_line_type, :read
      list :list_hr_resume_line_types, :read
    end

    mutations do
      create :create_hr_resume_line_type, :create
      update :update_hr_resume_line_type, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "类型名称"
    end
    attribute :sequence, :integer do
      default 10
      public? true
      description "排序序号"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :resume_lines, UniboExPoc.HR.ResumeLine do
      public? true
      destination_attribute :line_type_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :sequence]
      validate present(:name)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:name, :sequence]
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
