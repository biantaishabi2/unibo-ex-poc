# Workflow: return_item_editing — 退货明细编辑流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> [*]
# ```
defmodule UniboExPoc.Sales.ReturnItem do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Sales,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "退货单明细（对齐 OFBiz ReturnItem）"
  end

  postgres do
    table "sales_return_items"
    repo UniboExPoc.Repo
  end

  graphql do
    type :sales_return_item

    mutations do
      create :create_sales_return_item, :create
      update :update_sales_return_item, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :return_item_type_id, :string do
      public? true
      description "退货项类型（对齐 OFBiz ReturnItemType，如 产品/服务）"
    end
    attribute :return_reason, :string do
      public? true
      description "退货原因（对齐 OFBiz return_reason_id 语义）"
    end
    attribute :return_type, :string do
      public? true
      description "退款方式（对齐 OFBiz return_type_id，如 现金退款/换货/商店信用）"
    end
    attribute :status_id, :string do
      public? true
      description "行状态（对齐 OFBiz status_id）"
    end
    attribute :description, :string do
      public? true
      description "退货项描述（对齐 OFBiz description）"
    end
    attribute :return_quantity, :decimal do
      allow_nil? false
      public? true
      description "承诺退货数量（对齐 OFBiz return_quantity）"
    end
    attribute :received_quantity, :decimal do
      public? true
      description "实际收到数量（对齐 OFBiz received_quantity）"
    end
    attribute :return_price, :decimal do
      allow_nil? false
      public? true
      description "退货单价（对齐 OFBiz return_price）"
    end
    attribute :product_name, :string do
      allow_nil? false
      public? true
      description "产品名称（业务扩展，OFBiz 通过 product_id 关联）"
    end
    attribute :refund_amount, :decimal do
      public? true
      description "退款总额（业务扩展，可 computed = return_quantity * return_price）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :return, UniboExPoc.Sales.Return do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:product_name, :description, :return_quantity, :return_price, :refund_amount, :return_reason, :return_type, :return_item_type_id, :status_id]
      argument :return_id, :uuid, allow_nil?: false
      change manage_relationship(:return_id, :return, type: :append, on_lookup: :relate)
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
      accept [:return_quantity, :return_price, :refund_amount, :received_quantity, :status_id]
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

  validations do
    validate compare(:return_quantity, greater_than: 0)
    validate compare(:return_price, greater_than_or_equal_to: 0)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
