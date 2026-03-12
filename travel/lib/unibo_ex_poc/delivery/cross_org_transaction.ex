# Workflow: cross_org_transaction_lifecycle — 跨组织事务最小编排闭环
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> confirm_source
#   create --> cancel
#   update --> confirm_source
#   update --> cancel
#   confirm_source --> create_mirror_purchase_order
#   confirm_source --> mark_failed
#   confirm_source --> cancel
#   create_mirror_purchase_order --> mark_fulfilled
#   create_mirror_purchase_order --> mark_failed
#   mark_fulfilled --> mark_settled
#   mark_fulfilled --> mark_failed
#   mark_settled --> [*]
#   mark_failed --> [*]
#   cancel --> [*]
# ```
defmodule UniboExPoc.Delivery.CrossOrgTransaction do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Delivery,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Delivery.CrossOrgTransaction.Notifier]

  resource do
    description "跨组织事务编排骨架，串联源销售单、镜像采购单与履约发货链路"
  end

  postgres do
    table "delivery_cross_org_transactions"
    repo UniboExPoc.Repo
    identity_index_names unique_cross_org_transaction_number: "idx_delivery_cross_org_transactions_unique_cross_org_t_bfa0b1b6"
  end

  graphql do
    type :delivery_cross_org_transaction

    queries do
      get :get_delivery_cross_org_transaction, :read
      list :list_delivery_cross_org_transactions, :read
    end

    mutations do
      create :create_delivery_cross_org_transaction, :create
      update :update_delivery_cross_org_transaction, :update
      update :confirm_source_delivery_cross_org_transaction, :confirm_source
      update :create_mirror_purchase_order_delivery_cross_org_transaction, :create_mirror_purchase_order
      update :mark_fulfilled_delivery_cross_org_transaction, :mark_fulfilled
      update :mark_settled_delivery_cross_org_transaction, :mark_settled
      update :mark_failed_delivery_cross_org_transaction, :mark_failed
      update :cancel_delivery_cross_org_transaction, :cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :transaction_number, :string do
      allow_nil? false
      public? true
      description "跨组织事务编号"
    end
    attribute :transaction_type, :atom do
      allow_nil? false
      constraints one_of: [:intercompany_sale_purchase]
      default :intercompany_sale_purchase
      public? true
      description "首个试点仅覆盖销售单驱动的镜像采购场景"
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:draft, :source_confirmed, :mirror_created, :fulfilled, :settled, :failed, :cancelled]
      default :draft
      public? true
      description "事务状态：草稿 -> 源单确认 -> 镜像单生成 -> 履约完成 -> 结算完成"
    end
    attribute :settlement_mode, :atom do
      constraints one_of: [:internal_invoice, :manual_reconciliation]
      default :internal_invoice
      public? true
      description "结算模式"
    end
    attribute :planned_ship_date, :utc_datetime do
      public? true
      description "计划发运时间"
    end
    attribute :mirror_failure_reason, :string do
      public? true
      description "镜像单据创建失败原因"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :source_party, UniboExPoc.Delivery.Party do
      public? true
      allow_nil? false
    end
    belongs_to :target_party, UniboExPoc.Delivery.Party do
      public? true
      allow_nil? false
    end
    belongs_to :source_sales_order, UniboExPoc.Sales.SalesOrder do
      public? true
      allow_nil? false
    end
    belongs_to :target_purchase_order, UniboExPoc.Purchasing.PurchaseOrder do
      public? true
    end
    has_many :shipments, UniboExPoc.Delivery.Shipment do
      public? true
      destination_attribute :cross_org_transaction_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Cross Org Transaction via Create. doc_url: graphql://contract/delivery/create_delivery_cross_org_transaction"
      primary? true
      accept [:transaction_number, :transaction_type, :settlement_mode, :planned_ship_date]
      argument :source_party_id, :uuid, allow_nil?: false
      argument :target_party_id, :uuid, allow_nil?: false
      argument :source_sales_order_id, :uuid, allow_nil?: false
      change manage_relationship(:source_party_id, :source_party, type: :append, on_lookup: :relate)
      change manage_relationship(:target_party_id, :target_party, type: :append, on_lookup: :relate)
      change manage_relationship(:source_sales_order_id, :source_sales_order, type: :append, on_lookup: :relate)
      validate present(:transaction_number)
      validate attribute_does_not_equal(:source_party_id, :arguments)
      # message: "source_party_id 与 target_party_id 不能相同"
      change set_attribute(:source_party_id, expr(^arg(:source_party_id)))
      change set_attribute(:target_party_id, expr(^arg(:target_party_id)))
      change set_attribute(:source_sales_order_id, expr(^arg(:source_sales_order_id)))
    end
    update :update do
      description "Update Cross Org Transaction via Update. doc_url: graphql://contract/delivery/update_delivery_cross_org_transaction"
      primary? true
      accept [:settlement_mode, :planned_ship_date]
      require_atomic? false
    end
    update :confirm_source do
      description "确认源销售单，允许开始镜像编排

确认源销售单，允许开始镜像编排. doc_url: graphql://contract/delivery/confirm_source_delivery_cross_org_transaction"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以确认源销售单"
      change set_attribute(:status, :source_confirmed)
      require_atomic? false
    end
    update :create_mirror_purchase_order do
      description "为对手方创建镜像采购订单，并建立事务关联

为对手方创建镜像采购订单，并建立事务关联. doc_url: graphql://contract/delivery/create_mirror_purchase_order_delivery_cross_org_transaction"
      accept []
      argument :target_purchase_order_id, :uuid, allow_nil?: false
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :source_confirmed do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :source_confirmed}))
        end
      end
      # message: "只有源单确认后才允许创建镜像采购单"
      change UniboExPoc.Delivery.Changes.CrossOrgTransaction.CreateMirrorPurchaseOrderCall5
      change set_attribute(:target_purchase_order_id, expr(^arg(:target_purchase_order_id)))
      change set_attribute(:status, :mirror_created)
      require_atomic? false
    end
    update :mark_fulfilled do
      description "标记已完成履约

标记已完成履约. doc_url: graphql://contract/delivery/mark_fulfilled_delivery_cross_org_transaction"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :mirror_created do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :mirror_created}))
        end
      end
      # message: "只有镜像单创建完成后才允许标记履约完成"
      change set_attribute(:status, :fulfilled)
      require_atomic? false
    end
    update :mark_settled do
      description "标记已完成结算

标记已完成结算. doc_url: graphql://contract/delivery/mark_settled_delivery_cross_org_transaction"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :fulfilled do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :fulfilled}))
        end
      end
      # message: "只有履约完成后才允许标记结算完成"
      change set_attribute(:status, :settled)
      require_atomic? false
    end
    update :mark_failed do
      description "标记镜像单或履约阶段失败

标记镜像单或履约阶段失败. doc_url: graphql://contract/delivery/mark_failed_delivery_cross_org_transaction"
      accept [:mirror_failure_reason]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:source_confirmed, :mirror_created, :fulfilled] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:source_confirmed, :mirror_created, :fulfilled]}))
        end
      end
      # message: "只有编排中的事务才能标记失败"
      change set_attribute(:status, :failed)
      require_atomic? false
    end
    update :cancel do
      description "取消跨组织事务

取消跨组织事务. doc_url: graphql://contract/delivery/cancel_delivery_cross_org_transaction"
      accept []
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:status, :cancelled)
      require_atomic? false
    end
  end

  identities do
    identity :unique_cross_org_transaction_number, [:transaction_number]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
