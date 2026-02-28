defmodule UniboV4.Sales.Return do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Sales,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Sales.Return.Notifier]

  postgres do
    table "returns"
    repo UniboV4.Repo
  end

  graphql do
    type :return

    queries do
      get :get_return, :read
      list :list_returns, :read
    end

    mutations do
      create :create_return, :create
      update :approve_return, :approve
      update :receive_return, :receive
      update :complete_return, :complete
      update :cancel_return, :cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :return_number, :string, allow_nil?: false
    attribute :status, :atom do
      constraints one_of: [:requested, :approved, :received, :completed, :cancelled]
      default :requested
    end
    attribute :return_date, :date, allow_nil?: false
    attribute :reason, :string, allow_nil?: false
    attribute :total_refund_amount, :decimal
    attribute :notes, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :items, UniboV4.Sales.ReturnItem
    belongs_to :sales_order, UniboV4.Sales.SalesOrder do
      allow_nil? false
    end
    belongs_to :customer, UniboV4.Sales.Customer do
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:return_number, :return_date, :reason, :notes]
      argument :items, {:array, :string}, allow_nil?: false
      argument :sales_order_id, :uuid, allow_nil?: false
      argument :customer_id, :uuid, allow_nil?: false
      change manage_relationship(:items, :items, type: :create)
      change manage_relationship(:sales_order_id, :sales_order, type: :append, on_lookup: :relate)
      change manage_relationship(:customer_id, :customer, type: :append, on_lookup: :relate)
      validate present(:return_number)
      validate present(:reason)
      # TODO: 跨实体聚合表达式暂不支持
    end
    update :approve do
      accept []
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :requested) do
        message "只有已申请状态可以审批"
      end
      change set_attribute(:status, :approved)
    end
    update :receive do
      accept []
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :approved) do
        message "只有已审批状态可以收货"
      end
      change set_attribute(:status, :received)
    end
    update :complete do
      accept []
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :received) do
        message "只有已收货状态可以完成"
      end
      change set_attribute(:status, :completed)
    end
    update :cancel do
      accept []
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :requested) do
        message "只有已申请状态可以取消"
      end
      change set_attribute(:status, :cancelled)
    end
  end

  identities do
    identity :unique_return_number, [:return_number]
  end

end
