defmodule UniboV4.Inventory.StockPicking do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Inventory.StockPicking.Notifier]

  postgres do
    table "stock_pickings"
    repo UniboV4.Repo
  end

  graphql do
    type :stock_picking

    queries do
      get :get_stock_picking, :read
      list :list_stock_pickings, :read
    end

    mutations do
      create :create_stock_picking, :create
      update :assign_stock_picking, :assign
      update :start_stock_picking, :start
      update :complete_stock_picking, :complete
      update :cancel_stock_picking, :cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :picking_number, :string, allow_nil?: false
    attribute :picking_type, :atom do
      allow_nil? false
      constraints one_of: [:inbound, :outbound, :internal]
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :assigned, :in_progress, :done, :cancelled]
      default :draft
    end
    attribute :scheduled_date, :date
    attribute :completed_date, :date
    attribute :notes, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :items, UniboV4.Inventory.StockPickingItem
    belongs_to :warehouse, UniboV4.Inventory.Warehouse do
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:picking_number, :picking_type, :scheduled_date, :notes]
      argument :items, {:array, :string}, allow_nil?: false
      argument :warehouse_id, :uuid, allow_nil?: false
      change manage_relationship(:items, :items, type: :create)
      change manage_relationship(:warehouse_id, :warehouse, type: :append, on_lookup: :relate)
      validate present(:picking_number)
    end
    update :assign do
      accept []
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :draft) do
        message "只有草稿状态可以分配"
      end
      change set_attribute(:status, :assigned)
    end
    update :start do
      accept []
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :assigned) do
        message "只有已分配状态可以开始"
      end
      change set_attribute(:status, :in_progress)
    end
    update :complete do
      accept []
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :in_progress) do
        message "只有进行中状态可以完成"
      end
      change set_attribute(:status, :done)
    end
    update :cancel do
      accept []
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_in(:status, [:draft, :assigned]) do
        message "只有草稿或已分配状态可以取消"
      end
      change set_attribute(:status, :cancelled)
    end
  end

  identities do
    identity :unique_picking_number, [:picking_number]
  end

end
