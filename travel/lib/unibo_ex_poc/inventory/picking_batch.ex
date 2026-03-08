# Workflow: picking_batch_lifecycle_flow — 批量拣货正常流转流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   action_confirm --> [*]
#   action_assign --> [*]
#   action_done --> [*]
# ```
# Workflow: picking_batch_cancel_flow — 批量拣货取消流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   action_confirm --> [*]
#   action_cancel --> [*]
# ```
defmodule UniboExPoc.Inventory.PickingBatch do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "批量拣货批次，将多个拣货单分组执行"
  end

  postgres do
    table "inventory_picking_batches"
    repo UniboExPoc.Repo
  end

  graphql do
    type :inventory_picking_batch

    queries do
      get :get_inventory_picking_batch, :read
      list :list_inventory_picking_batchs, :read
    end

    mutations do
      create :create_inventory_picking_batch, :create
      update :update_inventory_picking_batch, :update
      update :action_confirm_inventory_picking_batch, :action_confirm
      update :action_done_inventory_picking_batch, :action_done
      update :action_cancel_inventory_picking_batch, :action_cancel
      update :action_assign_inventory_picking_batch, :action_assign
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "批次名称，序列号自动生成"
    end
    attribute :state, :atom do
      constraints one_of: [:draft, :in_progress, :done, :cancel]
      default :draft
      public? true
      description "计算字段，由关联 picking_ids 状态聚合（全部 done/cancel → done，全部 cancel → cancel）"
    end
    attribute :scheduled_date, :utc_datetime do
      public? true
      description "计划日期，取关联 picking_ids 中最早的 scheduled_date"
    end
    attribute :is_wave, :boolean do
      default false
      public? true
      description "是否为 Wave 拣货（Wave 是按移动行而非整单分组的拣货方式）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :picking_ids, UniboExPoc.Inventory.StockPicking do
      public? true
      source_attribute :responsible_party_id
      destination_attribute :batch_id
    end
    belongs_to :responsible, UniboExPoc.Inventory.Party do
      public? true
      source_attribute :responsible_party_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:is_wave]
      argument :responsible_id, :uuid
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
      accept [:is_wave]
      argument :responsible_id, :uuid
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
    update :action_confirm do
      description "确认批次，状态 → in_progress，对所有关联 picking 调用 action_confirm"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以确认"
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
    update :action_done do
      description "验证批次，过滤空拣货、执行 sanity_check、调用 button_validate"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :in_progress do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :in_progress}))
        end
      end
      # message: "只有进行中状态可以验证"
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
    update :action_cancel do
      description "取消批次，清空 picking_ids"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current in [:draft, :in_progress] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must be one of %{values}", vars: %{values: [:draft, :in_progress]}))
        end
      end
      # message: "只有草稿或进行中状态可以取消"
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
    update :action_assign do
      description "检查可用性，对关联 picking 调用 action_assign"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :in_progress do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :in_progress}))
        end
      end
      # message: "只有进行中状态可以检查可用性"
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
