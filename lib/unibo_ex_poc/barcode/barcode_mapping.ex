# Workflow: mapping_lifecycle — 条码映射生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> register
#   register --> update
#   register --> deactivate
#   register --> destroy
#   update --> deactivate
#   update --> destroy
#   deactivate --> update
#   deactivate --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Barcode.BarcodeMapping do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Barcode,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource],
    notifiers: [UniboExPoc.Barcode.BarcodeMapping.Notifier]

  resource do
    description "条码与业务对象映射，记录条码值到产品、批次、库位、资产等的关联关系"
  end

  postgres do
    table "barcode_mappings"
    repo UniboExPoc.Repo
  end

  graphql do
    type :barcode_barcode_mapping

    queries do
      get :get_barcode_barcode_mapping, :read
      list :list_barcode_barcode_mappings, :read
    end

    mutations do
      create :create_register_barcode_barcode_mapping, :register
      update :update_barcode_barcode_mapping, :update
      update :deactivate_barcode_barcode_mapping, :deactivate
      destroy :delete_barcode_barcode_mapping, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :barcode_value, :string do
      allow_nil? false
      public? true
      description "条码值（如EAN-13编码\"6901234567890\"）"
    end
    attribute :resource_type, :string do
      allow_nil? false
      public? true
      description "关联的业务资源类型（开放式，如 product、lot、location、asset、package、employee 等）"
    end
    attribute :resource_id, :string do
      allow_nil? false
      public? true
      description "关联的业务资源ID"
    end
    attribute :active, :boolean do
      default true
      public? true
      description "是否有效"
    end
    attribute :description, :string do
      public? true
      description "映射备注"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :nomenclature, UniboExPoc.Barcode.BarcodeNomenclature do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy]
    create :register do
      primary? true
      accept [:barcode_value, :resource_type, :resource_id, :description]
      argument :nomenclature_id, :uuid
      validate present(:barcode_value)
      validate present(:resource_type)
      validate present(:resource_id)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:resource_type, :resource_id, :description, :active]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :deactivate do
      description "停用条码映射"
      accept []
      change UniboExPoc.Barcode.Changes.BarcodeMapping.ComputeActive
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_barcode_value, [:barcode_value]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
