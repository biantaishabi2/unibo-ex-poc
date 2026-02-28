defmodule UniboV4.Inventory.StockMove do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Inventory.StockMove.Notifier]

  postgres do
    table "stock_moves"
    repo UniboV4.Repo
  end

  graphql do
    type :stock_move

    queries do
      get :get_stock_move, :read
      list :list_stock_moves, :read
    end

    mutations do
      create :create_stock_move, :create
      update :confirm_stock_move, :confirm
      update :complete_stock_move, :complete
      update :cancel_stock_move, :cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :move_number, :string, allow_nil?: false
    attribute :status, :atom do
      constraints one_of: [:draft, :confirmed, :in_transit, :done, :cancelled]
      default :draft
    end
    attribute :move_date, :date, allow_nil?: false
    attribute :notes, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :source_warehouse, UniboV4.Inventory.Warehouse
    belongs_to :destination_warehouse, UniboV4.Inventory.Warehouse
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:move_number, :move_date, :notes]
      argument :source_warehouse_id, :uuid
      argument :destination_warehouse_id, :uuid
      validate present(:move_number)
    end
    update :confirm do
      accept []
      validate attribute_equals(:status, :draft) do
        message "只有草稿状态可以确认"
      end
      change set_attribute(:status, :confirmed)
    end
    update :complete do
      accept []
      validate attribute_in(:status, [:confirmed, :in_transit]) do
        message "只有已确认或在途状态可以完成"
      end
      change set_attribute(:status, :done)
    end
    update :cancel do
      accept []
      validate attribute_in(:status, [:draft, :confirmed]) do
        message "只有草稿或已确认状态可以取消"
      end
      change set_attribute(:status, :cancelled)
    end
  end

  identities do
    identity :unique_move_number, [:move_number]
  end

end
