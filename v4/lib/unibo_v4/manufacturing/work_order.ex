defmodule UniboV4.Manufacturing.WorkOrder do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "work_orders"
    repo UniboV4.Repo
  end

  graphql do
    type :work_order

    queries do
      get :get_work_order, :read
      list :list_work_orders, :read
    end

    mutations do
      create :create_work_order, :create
      update :start_work_order, :start
      update :complete_work_order, :complete
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :sequence, :integer, allow_nil?: false, public?: true
    attribute :status, :atom do
      constraints one_of: [:pending, :in_progress, :done, :cancelled]
      default :pending
        public? true
    end
    attribute :planned_duration_hours, :decimal, public?: true
    attribute :actual_duration_hours, :decimal, public?: true
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :manufacturing_order, UniboV4.Manufacturing.ManufacturingOrder do
      allow_nil? false
        public? true
    end
    belongs_to :work_center, UniboV4.Manufacturing.WorkCenter, public?: true
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :sequence, :planned_duration_hours, :notes]
      argument :manufacturing_order_id, :uuid, allow_nil?: false
      change manage_relationship(:manufacturing_order_id, :manufacturing_order, type: :append, on_lookup: :relate)
      validate present(:name)
    end
    update :start do
      accept []
      validate attribute_equals(:status, :pending) do
        message "只有待处理状态可以开始"
      end
      change set_attribute(:status, :in_progress)
    end
    update :complete do
      accept [:actual_duration_hours]
      validate attribute_equals(:status, :in_progress) do
        message "只有进行中状态可以完成"
      end
      change set_attribute(:status, :done)
    end
  end

end
