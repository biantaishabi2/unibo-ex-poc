# Workflow: lot_write_flow — 批次/序列号写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.Inventory.Lot do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "批次/序列号"
  end

  postgres do
    table "inventory_lots"
    repo UniboExPoc.Repo
  end

  graphql do
    type :inventory_lot

    queries do
      get :get_inventory_lot, :read
      list :list_inventory_lots, :read
    end

    mutations do
      create :create_inventory_lot, :create
      update :update_inventory_lot, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :lot_number, :string do
      allow_nil? false
      public? true
      description "批次号"
    end
    attribute :product_code, :string do
      allow_nil? false
      public? true
    end
    attribute :expiration_date, :utc_datetime do
      public? true
      description "到期日（product_expiry 模块），产品收货日 + expiration_time 天"
    end
    attribute :use_date, :utc_datetime do
      public? true
      description "最佳食用/使用日期，从到期日倒推 use_time 天"
    end
    attribute :removal_date, :utc_datetime do
      public? true
      description "移除日期，用于 FEFO 出库策略排序"
    end
    attribute :alert_date, :utc_datetime do
      public? true
      description "提醒日期，到期预警触发时间"
    end
    attribute :manufacturing_date, :date do
      public? true
      description "生产日期"
    end
    attribute :product_expiry_alert, :boolean do
      default false
      public? true
      description "是否已过期（expiration_date <= 当前时间）"
    end
    attribute :product_expiry_reminded, :boolean do
      default false
      public? true
      description "是否已发送过期提醒"
    end
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:lot_number, :product_code, :expiration_date, :use_date, :removal_date, :alert_date, :manufacturing_date, :product_expiry_reminded, :notes]
      validate present(:lot_number)
      validate present(:product_code)
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
      accept [:expiration_date, :use_date, :removal_date, :alert_date, :product_expiry_reminded, :notes]
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
    identity :unique_lot_number, [:lot_number]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
