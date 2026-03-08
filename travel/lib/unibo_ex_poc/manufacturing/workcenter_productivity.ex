# Workflow: workcenter_productivity_tracking_flow — 工作中心生产率记录创建与更新流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.Manufacturing.WorkcenterProductivity do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "工作中心工时/生产率记录"
  end

  postgres do
    table "manufacturing_workcenter_productivities"
    repo UniboExPoc.Repo
  end

  graphql do
    type :manufacturing_workcenter_productivity

    mutations do
      create :create_manufacturing_workcenter_productivity, :create
      update :update_manufacturing_workcenter_productivity, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :date_start, :utc_datetime do
      allow_nil? false
      public? true
      description "开始时间"
    end
    attribute :date_end, :utc_datetime do
      public? true
      description "结束时间"
    end
    attribute :duration, :decimal do
      public? true
      description "时长（分钟，date_end - date_start）"
    end
    attribute :loss_type, :atom do
      constraints one_of: [:productive, :performance, :quality, :availability]
      default :productive
      public? true
      description "损失类型分类"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :work_order, UniboExPoc.Manufacturing.WorkOrder do
      public? true
      allow_nil? false
    end
    belongs_to :work_center, UniboExPoc.Manufacturing.WorkCenter do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:date_start, :date_end, :loss_type]
      argument :work_order_id, :uuid, allow_nil?: false
      change manage_relationship(:work_order_id, :work_order, type: :append, on_lookup: :relate)
      argument :work_center_id, :uuid, allow_nil?: false
      change manage_relationship(:work_center_id, :work_center, type: :append, on_lookup: :relate)
      validate present(:date_start)
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
      accept [:date_end, :loss_type]
      # skipped: validate compare :date_end (incompatible with bulk update atomic path)
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
