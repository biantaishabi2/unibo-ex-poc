# Workflow: dial_plan_lifecycle — 拨号计划创建、激活、停用、维护与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   activate --> [*]
#   deactivate --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.IoT.DialPlan do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.IoT,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "来电路由规则的容器，管理从入站号码到最终处理的完整呼叫流程"
  end

  postgres do
    table "io_t_dial_plans"
    repo UniboExPoc.Repo
  end

  graphql do
    type :io_t_dial_plan

    queries do
      get :get_io_t_dial_plan, :read
      list :list_io_t_dial_plans, :read
    end

    mutations do
      create :create_io_t_dial_plan, :create
      update :update_io_t_dial_plan, :update
      update :activate_io_t_dial_plan, :activate
      update :deactivate_io_t_dial_plan, :deactivate
      destroy :delete_io_t_dial_plan, :destroy
    end

  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      generated? true
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
      description "名称"
    end
    attribute :description, :string do
      public? true
      description "描述"
    end
    attribute :is_active, :boolean do
      default true
      public? true
      description "是否激活"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    has_many :elements, UniboExPoc.IoT.DialPlanElement do
      public? true
      source_attribute :org_id
      destination_attribute :dial_plan_id
    end
    has_many :incoming_numbers, UniboExPoc.IoT.IncomingNumber do
      public? true
      source_attribute :org_id
      destination_attribute :dial_plan_id
    end
    belongs_to :org, UniboExPoc.IoT.Org do
      public? true
      allow_nil? false
      attribute_type :integer
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :description, :is_active, :org_id]
      argument :org_id, :integer, allow_nil?: false
      change manage_relationship(:org_id, :org, type: :append, on_lookup: :relate)
      validate present(:name)
      validate present(:org_id)
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
      accept [:name, :description]
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
    update :activate do
      description "激活拨号计划"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :is_active)
        if current == false do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :is_active, message: "must equal %{value}", vars: %{value: false}))
        end
      end
      # message: "已激活的计划不能重复激活"
      change set_attribute(:is_active, true)
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
    update :deactivate do
      description "停用拨号计划"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :is_active)
        if current == true do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :is_active, message: "must equal %{value}", vars: %{value: true}))
        end
      end
      # message: "已停用的计划不能重复停用"
      change set_attribute(:is_active, false)
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
    identity :unique_name_per_org, [:name, :org_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:elements, :incoming_numbers]
  end

end
