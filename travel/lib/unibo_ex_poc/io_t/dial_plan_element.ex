# Workflow: dial_plan_element_lifecycle — 拨号计划元素创建、配置、排序与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   reorder --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.IoT.DialPlanElement do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.IoT,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "拨号计划中的单个路由节点，支持串联和条件分支"
  end

  postgres do
    table "io_t_dial_plan_elements"
    repo UniboExPoc.Repo
  end

  graphql do
    type :io_t_dial_plan_element

    queries do
      get :get_io_t_dial_plan_element, :read
      list :list_io_t_dial_plan_elements, :read
    end

    mutations do
      create :create_io_t_dial_plan_element, :create
      update :update_io_t_dial_plan_element, :update
      update :reorder_io_t_dial_plan_element, :reorder
      destroy :delete_io_t_dial_plan_element, :destroy
    end

  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      generated? true
      public? true
    end
    attribute :element_type, :atom do
      allow_nil? false
      constraints one_of: [:call, :play_audio, :voicemail, :hangup, :queue, :conference, :menu, :switch, :digital_receptionist, :dispatcher, :time_condition, :access_list]
      public? true
      description "元素类型"
    end
    attribute :position, :integer do
      default 0
      public? true
      description "排序位置"
    end
    attribute :config, :map do
      public? true
      description "元素配置（JSONB，内容因 element_type 而异）"
    end
    attribute :config_schema_version, :integer do
      default 1
      public? true
      description "config 结构版本号（迁移用）"
    end
    attribute :timeout_seconds, :integer do
      public? true
      description "超时时间"
    end
    attribute :is_terminal, :boolean do
      default false
      public? true
      description "是否终端节点（voicemail、hangup 为 true）"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :dial_plan, UniboExPoc.IoT.DialPlan do
      public? true
      allow_nil? false
      attribute_type :integer
    end
    belongs_to :next_element, UniboExPoc.IoT.DialPlanElement do
      public? true
      attribute_type :integer
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:dial_plan_id, :element_type, :position, :config, :config_schema_version, :next_element_id, :timeout_seconds, :is_terminal]
      argument :dial_plan_id, :integer, allow_nil?: false
      change manage_relationship(:dial_plan_id, :dial_plan, type: :append, on_lookup: :relate)
      validate present(:dial_plan_id)
      validate present(:element_type)
      # validation: terminal_no_next
      # validation: config_schema_validation
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
      accept [:element_type, :position, :config, :config_schema_version, :next_element_id, :timeout_seconds, :is_terminal]
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
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
    update :reorder do
      description "调整排序位置"
      argument :new_position, :integer, allow_nil?: false
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate compare :position (incompatible with bulk update atomic path)
      change set_attribute(:position, ^arg(:new_position))
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

  archive do
  end

end
