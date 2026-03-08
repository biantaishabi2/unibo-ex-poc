# Workflow: fsm_stage_management — 现场服务阶段管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboExPoc.Helpdesk.FsmTaskStage do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "现场服务任务阶段（可自定义的看板列）"
  end

  postgres do
    table "helpdesk_fsm_task_stages"
    repo UniboExPoc.Repo
  end

  graphql do
    type :helpdesk_fsm_task_stage

    queries do
      get :get_helpdesk_fsm_task_stage, :read
      list :list_helpdesk_fsm_task_stages, :read
    end

    mutations do
      create :create_helpdesk_fsm_task_stage, :create
      update :update_helpdesk_fsm_task_stage, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "阶段名称（如 New、Scheduled、In Progress、Done、Cancelled）"
    end
    attribute :sequence, :integer do
      allow_nil? false
      default 10
      public? true
      description "排序权重"
    end
    attribute :fold, :boolean do
      allow_nil? false
      default false
      public? true
      description "是否折叠/关闭状态（Done 和 Cancelled 为 true）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :service_orders, UniboExPoc.Helpdesk.FieldServiceOrder do
      public? true
      destination_attribute :stage_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :sequence, :fold]
      validate present(:name)
      # message: "阶段名称必填"
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
      accept [:name, :sequence, :fold]
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

  identities do
    identity :unique_fsm_stage_name, [:name]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
