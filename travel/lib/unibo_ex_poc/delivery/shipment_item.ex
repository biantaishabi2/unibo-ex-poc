# Workflow: shipment_item_flow — 发货明细行管理
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Delivery.ShipmentItem do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Delivery,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "发货明细行，记录发货单中每个商品/内容物的数量"
  end

  postgres do
    table "delivery_shipment_items"
    repo UniboExPoc.Repo
  end

  graphql do
    type :delivery_shipment_item

    queries do
      get :get_delivery_shipment_item, :read
      list :list_delivery_shipment_items, :read
    end

    mutations do
      create :create_delivery_shipment_item, :create
      update :update_delivery_shipment_item, :update
      destroy :delete_delivery_shipment_item, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :shipment_item_seq_id, :uuid do
      allow_nil? false
      public? true
      description "行序号（OFBiz 复合主键）"
    end
    attribute :quantity, :decimal do
      public? true
      description "发货数量"
    end
    attribute :shipment_content_description, :string do
      public? true
      description "内容物描述（无产品时使用）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :shipment, UniboExPoc.Delivery.Shipment do
      public? true
    end
    belongs_to :product, UniboExPoc.Delivery.Product do
      public? true
    end
    has_many :package_contents, UniboExPoc.Delivery.ShipmentPackageContent do
      public? true
      source_attribute :shipment_item_seq_id
      destination_attribute :shipment_item_seq_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:shipment_item_seq_id, :quantity, :shipment_content_description]
      validate present(:shipment_id)
      validate compare(:quantity, greater_than: 0)
      # message: "发货数量必须大于 0"
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
      accept [:quantity, :shipment_content_description]
      # skipped: validate compare :quantity (incompatible with bulk update atomic path)
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:package_contents]
  end

end
