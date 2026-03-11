# Workflow: return_lifecycle — 退货处理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> approve
#   create --> cancel
#   approve --> receive
#   approve --> cancel
#   receive --> complete
#   complete --> [*] : completed
#   cancel --> [*]
# ```
defmodule UniboExPoc.Sales.Return do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Sales,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Sales.Return.Notifier]

  resource do
    description "销售退货单"
  end

  postgres do
    table "sales_returns"
    repo UniboExPoc.Repo
    identity_index_names unique_return_number: "idx_sales_returns_unique_return_number"
  end

  graphql do
    type :sales_return

    queries do
      get :get_sales_return, :read
      list :list_sales_returns, :read
      get :get_list_sales_return, :list
      list :list_list_sales_returns, :list
      get :get_search_sales_return, :search
      list :list_search_sales_returns, :search
      get :get_get_sales_return, :get
      list :list_get_sales_returns, :get
      get :get_preview_sales_return, :preview
      list :list_preview_sales_returns, :preview
      get :get_compute_sales_return, :compute
      list :list_compute_sales_returns, :compute
      get :get_lookup_sales_return, :lookup
      list :list_lookup_sales_returns, :lookup
    end

    mutations do
      create :create_sales_return, :create
      update :approve_sales_return, :approve
      update :receive_sales_return, :receive
      update :complete_sales_return, :complete
      update :cancel_sales_return, :cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :return_number, :string do
      allow_nil? false
      public? true
      description "退货单号"
    end
    attribute :status, :atom do
      constraints one_of: [:requested, :approved, :received, :completed, :cancelled]
      default :requested
      public? true
    end
    attribute :return_date, :date do
      allow_nil? false
      public? true
    end
    attribute :reason, :string do
      allow_nil? false
      public? true
      description "退货原因"
    end
    attribute :total_refund_amount, :decimal do
      public? true
      description "退款总金额"
    end
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :items, UniboExPoc.Sales.ReturnItem do
      public? true
    end
    belongs_to :sales_order, UniboExPoc.Sales.SalesOrder do
      public? true
      allow_nil? false
    end
    belongs_to :customer, UniboExPoc.Sales.Customer do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Return via Create. doc_url: graphql://contract/sales/create_sales_return"
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
      change UniboExPoc.Sales.Changes.Return.ComputeTotalRefundAmount
    end
    read :list do
      description "列表查询"
    end
    read :search do
      description "条件检索"
    end
    read :get do
      description "详情查询"
    end
    read :preview do
      description "预览查询"
    end
    read :compute do
      description "计算查询"
    end
    read :lookup do
      description "快速检索"
    end
    update :approve do
      description "审批退货

审批退货. doc_url: graphql://contract/sales/approve_sales_return"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :requested do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :requested}))
        end
      end
      # message: "只有已申请状态可以审批"
      change set_attribute(:status, :approved)
      require_atomic? false
    end
    update :receive do
      description "确认收到退货商品

确认收到退货商品. doc_url: graphql://contract/sales/receive_sales_return"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :approved do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :approved}))
        end
      end
      # message: "只有已审批状态可以收货"
      change set_attribute(:status, :received)
      require_atomic? false
    end
    update :complete do
      description "完成退货（退款）

完成退货（退款）. doc_url: graphql://contract/sales/complete_sales_return"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :received do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :received}))
        end
      end
      # message: "只有已收货状态可以完成"
      change set_attribute(:status, :completed)
      require_atomic? false
    end
    update :cancel do
      description "取消退货

取消退货. doc_url: graphql://contract/sales/cancel_sales_return"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :requested do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :requested}))
        end
      end
      # message: "只有已申请状态可以取消"
      change set_attribute(:status, :cancelled)
      require_atomic? false
    end
  end

  identities do
    identity :unique_return_number, [:return_number]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
