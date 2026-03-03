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
defmodule UniboV4.Sales.Return do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Sales,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Sales.Return.Notifier]

  postgres do
    table "sales_returns"
    repo UniboV4.Repo
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
    end
    attribute :total_refund_amount, :decimal, public?: true
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :items, UniboV4.Sales.ReturnItem do
      public? true
    end
    belongs_to :sales_order, UniboV4.Sales.SalesOrder do
      public? true
      allow_nil? false
    end
    belongs_to :customer, UniboV4.Sales.Customer do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:return_number, :return_date, :reason, :notes]
      argument :items, {:array, :map}, allow_nil?: false
      argument :sales_order_id, :uuid, allow_nil?: false
      argument :customer_id, :uuid, allow_nil?: false
      change manage_relationship(:items, :items, type: :create)
      change manage_relationship(:sales_order_id, :sales_order, type: :append, on_lookup: :relate)
      change manage_relationship(:customer_id, :customer, type: :append, on_lookup: :relate)
      validate present(:return_number)
      validate present(:reason)
      # TODO: 跨实体聚合表达式暂不支持
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    read :list do
    end
    read :search do
    end
    read :get do
    end
    read :preview do
    end
    read :compute do
    end
    read :lookup do
    end
    update :approve do
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
    update :receive do
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
    update :complete do
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
    update :cancel do
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
    identity :unique_return_number, [:return_number]
  end

end
