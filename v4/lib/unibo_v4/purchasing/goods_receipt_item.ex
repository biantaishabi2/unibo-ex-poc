defmodule UniboV4.Purchasing.GoodsReceiptItem do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "goods_receipt_items"
    repo UniboV4.Repo
  end

  graphql do
    type :goods_receipt_item

    mutations do
      create :create_goods_receipt_item, :create
      update :update_goods_receipt_item, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_name, :string, allow_nil?: false
    attribute :quantity_received, :integer, allow_nil?: false
    attribute :quantity_accepted, :integer
    attribute :quantity_rejected, :integer, default: 0
    attribute :rejection_reason, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :receipt, UniboV4.Purchasing.GoodsReceipt do
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:product_name, :quantity_received, :quantity_accepted, :quantity_rejected, :rejection_reason]
      argument :receipt_id, :uuid, allow_nil?: false
      change manage_relationship(:receipt_id, :receipt, type: :append, on_lookup: :relate)
    end
    update :update do
      primary? true
      accept [:quantity_accepted, :quantity_rejected, :rejection_reason]
    end
  end

  validations do
    validate compare(:quantity_received, greater_than: 0)
  end

end
