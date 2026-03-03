# Workflow: requisition_lifecycle_flow — 采购申请生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   action_in_progress --> [*]
#   action_open --> [*]
#   action_done --> [*]
#   action_cancel --> [*]
# ```
# Workflow: requisition_reopen_flow — 取消后重新发起采购申请
# ```mermaid
# stateDiagram-v2
#   [*] --> action_cancel
#   action_cancel --> [*]
#   action_draft --> [*]
#   action_in_progress --> [*]
# ```
defmodule UniboV4.Purchasing.PurchaseRequisition do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Purchasing.PurchaseRequisition.Notifier]

  postgres do
    table "purchasing_purchase_requisitions"
    repo UniboV4.Repo
  end

  graphql do
    type :purchasing_purchase_requisition

    queries do
      get :get_purchasing_purchase_requisition, :read
      list :list_purchasing_purchase_requisitions, :read
      get :get_list_purchasing_purchase_requisition, :list
      list :list_list_purchasing_purchase_requisitions, :list
      get :get_search_purchasing_purchase_requisition, :search
      list :list_search_purchasing_purchase_requisitions, :search
      get :get_get_purchasing_purchase_requisition, :get
      list :list_get_purchasing_purchase_requisitions, :get
      get :get_preview_purchasing_purchase_requisition, :preview
      list :list_preview_purchasing_purchase_requisitions, :preview
      get :get_compute_purchasing_purchase_requisition, :compute
      list :list_compute_purchasing_purchase_requisitions, :compute
      get :get_lookup_purchasing_purchase_requisition, :lookup
      list :list_lookup_purchasing_purchase_requisitions, :lookup
    end

    mutations do
      create :create_purchasing_purchase_requisition, :create
      update :action_in_progress_purchasing_purchase_requisition, :action_in_progress
      update :action_open_purchasing_purchase_requisition, :action_open
      update :action_done_purchasing_purchase_requisition, :action_done
      update :action_cancel_purchasing_purchase_requisition, :action_cancel
      update :action_draft_purchasing_purchase_requisition, :action_draft
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :origin, :string, public?: true
    attribute :state, :atom do
      constraints one_of: [:draft, :ongoing, :in_progress, :open, :done, :cancel]
      default :draft
      public? true
    end
    attribute :description, :string, public?: true
    attribute :ordering_date, :date, public?: true
    attribute :date_end, :utc_datetime, public?: true
    attribute :schedule_date, :date, public?: true
    attribute :notes, :string, public?: true
    attribute :currency, :string do
      default "CNY"
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :items, UniboV4.Purchasing.PurchaseRequisitionItem do
      public? true
      destination_attribute :requisition_id
    end
    belongs_to :type, UniboV4.Purchasing.PurchaseRequisitionType do
      public? true
      allow_nil? false
    end
    belongs_to :vendor, UniboV4.Purchasing.Supplier do
      public? true
    end
    belongs_to :user, UniboV4.Purchasing.User do
      public? true
    end
    has_many :purchase_orders, UniboV4.Purchasing.PurchaseOrder do
      public? true
      destination_attribute :requisition_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :origin, :description, :ordering_date, :date_end, :schedule_date, :currency, :notes]
      argument :items, {:array, :string}, allow_nil?: false
      argument :type_id, :uuid, allow_nil?: false
      argument :vendor_id, :uuid
      change manage_relationship(:items, :items, type: :create)
      change manage_relationship(:type_id, :type, type: :append, on_lookup: :relate)
      validate present(:name)
      change relate_actor(:user)
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
    update :action_in_progress do
      primary? true
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
      change set_attribute(:state, :in_progress)
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
    update :action_open do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current in [:in_progress, :ongoing] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must be one of %{values}", vars: %{values: [:in_progress, :ongoing]}))
        end
      end
      # message: "只有进行中状态可以进入投标选择"
      change set_attribute(:state, :open)
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
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :open do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :open}))
        end
      end
      # message: "只有开放状态可以关闭"
      change set_attribute(:state, :done)
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
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current in [:draft, :in_progress, :ongoing, :open] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must be one of %{values}", vars: %{values: [:draft, :in_progress, :ongoing, :open]}))
        end
      end
      # message: "仅未完成状态的协议允许取消"
      change set_attribute(:state, :cancel)
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
    update :action_draft do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :cancel do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :cancel}))
        end
      end
      # message: "只有已取消状态可以重置为草稿"
      change set_attribute(:state, :draft)
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
    identity :unique_requisition_name, [:name]
  end

end
