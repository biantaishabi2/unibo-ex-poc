# Workflow: workcenter_productivity_tracking_flow — 工作中心生产率记录创建与更新流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.Manufacturing.WorkcenterProductivity do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Manufacturing,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "manufacturing_workcenter_productivities"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :date_start, :utc_datetime do
      allow_nil? false
      public? true
    end
    attribute :date_end, :utc_datetime, public?: true
    attribute :duration, :decimal, public?: true
    attribute :loss_type, :atom do
      constraints one_of: [:productive, :performance, :quality, :availability]
      default :productive
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :work_order, UniboV4.Manufacturing.WorkOrder do
      public? true
      allow_nil? false
    end
    belongs_to :work_center, UniboV4.Manufacturing.WorkCenter do
      public? true
      allow_nil? false
    end
  end

  actions do
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
      # skipped: validate custom : (incompatible with bulk update atomic path)
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

end
