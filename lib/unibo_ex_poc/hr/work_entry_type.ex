# Workflow: work_entry_type_write_flow — WorkEntryType 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.HR.WorkEntryType do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "工时条目类型（如\"正常出勤\"、\"加班\"、\"病假\"）"
  end

  postgres do
    table "hr_work_entry_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :hr_work_entry_type

    queries do
      get :get_hr_work_entry_type, :read
      list :list_hr_work_entry_types, :read
    end

    mutations do
      create :create_hr_work_entry_type, :create
      update :update_hr_work_entry_type, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "类型名称"
    end
    attribute :code, :string do
      allow_nil? false
      public? true
      description "唯一编码"
    end
    attribute :external_code, :string do
      public? true
      description "外部系统编码"
    end
    attribute :color, :integer do
      public? true
      description "颜色标识"
    end
    attribute :sequence, :integer do
      default 25
      public? true
      description "排序序号"
    end
    attribute :is_active, :boolean do
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :work_entries, UniboExPoc.HR.WorkEntry do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :code, :external_code, :color, :sequence]
      validate present(:name)
      validate present(:code)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :external_code, :color, :sequence, :is_active]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_work_entry_type_code, [:code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
