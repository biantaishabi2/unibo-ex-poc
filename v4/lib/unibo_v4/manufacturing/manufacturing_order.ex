defmodule UniboV4.Manufacturing.ManufacturingOrder do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Manufacturing.ManufacturingOrder.Notifier]

  postgres do
    table "manufacturing_orders"
    repo UniboV4.Repo
  end

  graphql do
    type :manufacturing_order

    queries do
      get :get_manufacturing_order, :read
      list :list_manufacturing_orders, :read
    end

    mutations do
      create :create_manufacturing_order, :create
      update :confirm_manufacturing_order, :confirm
      update :start_manufacturing_order, :start
      update :complete_manufacturing_order, :complete
      update :cancel_manufacturing_order, :cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :order_number, :string, allow_nil?: false, public?: true
    attribute :product_name, :string, allow_nil?: false, public?: true
    attribute :product_code, :string, allow_nil?: false, public?: true
    attribute :quantity, :decimal, allow_nil?: false, public?: true
    attribute :quantity_produced, :decimal, default: 0, public?: true
    attribute :status, :atom do
      constraints one_of: [:draft, :confirmed, :in_progress, :done, :cancelled]
      default :draft
        public? true
    end
    attribute :planned_start_date, :date, public?: true
    attribute :planned_end_date, :date, public?: true
    attribute :actual_start_date, :date, public?: true
    attribute :actual_end_date, :date, public?: true
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :bom, UniboV4.Manufacturing.BillOfMaterials, public?: true
    has_many :work_orders, UniboV4.Manufacturing.WorkOrder
    belongs_to :work_center, UniboV4.Manufacturing.WorkCenter, public?: true
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:order_number, :product_name, :product_code, :quantity, :planned_start_date, :planned_end_date, :notes]
      argument :bom_id, :uuid
      validate present(:order_number)
    end
    update :confirm do
      accept []
      validate attribute_equals(:status, :draft) do
        message "只有草稿状态可以确认"
      end
      change set_attribute(:status, :confirmed)
    end
    update :start do
      accept []
      validate attribute_equals(:status, :confirmed) do
        message "只有已确认状态可以开始"
      end
      change set_attribute(:status, :in_progress)
    end
    update :complete do
      accept []
      validate attribute_equals(:status, :in_progress) do
        message "只有进行中状态可以完成"
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

  validations do
    validate compare(:quantity, greater_than: 0)
  end

  identities do
    identity :unique_order_number, [:order_number]
  end

end
