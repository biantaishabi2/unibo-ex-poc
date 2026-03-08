# Workflow: rule_lifecycle — 解析规则维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> reorder
#   create --> destroy
#   update --> reorder
#   update --> destroy
#   reorder --> update
#   reorder --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Barcode.BarcodeRule do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Barcode,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "条码解析规则，定义条码模式匹配和字段映射，支持普通编码和GS1-128扩展"
  end

  postgres do
    table "barcode_rules"
    repo UniboExPoc.Repo
  end

  graphql do
    type :barcode_barcode_rule

    queries do
      get :get_barcode_barcode_rule, :read
      list :list_barcode_barcode_rules, :read
    end

    mutations do
      create :create_barcode_barcode_rule, :create
      update :update_barcode_barcode_rule, :update
      update :reorder_barcode_barcode_rule, :reorder
      destroy :delete_barcode_barcode_rule, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "规则名称"
    end
    attribute :sequence, :integer do
      allow_nil? false
      default 10
      public? true
      description "匹配优先级（越小越先匹配）"
    end
    attribute :encoding, :atom do
      allow_nil? false
      constraints one_of: [:any, :ean13, :ean8, :upca, :gs1_128, :gs1_datamatrix]
      default :any
      public? true
      description "条码编码类型"
    end
    attribute :barcode_type, :atom do
      allow_nil? false
      constraints one_of: [:product, :alias, :quantity, :lot, :location, :location_dest, :package, :package_type, :use_date, :expiration_date, :pack_date]
      default :product
      public? true
      description "匹配后关联的业务类型"
    end
    attribute :pattern, :string do
      allow_nil? false
      default ".*"
      public? true
      description "匹配正则表达式，支持{NND}数值占位符；GS1模式需含两个捕获组"
    end
    attribute :alias, :string do
      public? true
      description "barcode_type=alias时重定向到此条码值"
    end
    attribute :gs1_content_type, :atom do
      constraints one_of: [:date, :measure, :identifier, :alpha]
      public? true
      description "GS1内容类型（encoding=gs1_128时使用）"
    end
    attribute :gs1_decimal_usage, :boolean do
      default false
      public? true
      description "AI末位是否表示小数位数（GS1 measure类型）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :nomenclature, UniboExPoc.Barcode.BarcodeNomenclature do
      public? true
      allow_nil? false
    end
    belongs_to :gs1_ai, UniboExPoc.Barcode.GS1ApplicationIdentifier do
      public? true
    end
    has_many :translations, UniboExPoc.Barcode.BarcodeRuleTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :sequence, :encoding, :barcode_type, :pattern, :alias, :gs1_content_type, :gs1_decimal_usage]
      argument :nomenclature_id, :uuid, allow_nil?: false
      argument :gs1_ai_id, :uuid
      change manage_relationship(:nomenclature_id, :nomenclature, type: :append, on_lookup: :relate)
      validate present(:name)
      validate present(:nomenclature_id)
      validate present(:pattern)
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
      accept [:name, :sequence, :encoding, :barcode_type, :pattern, :alias, :gs1_content_type, :gs1_decimal_usage]
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
    update :reorder do
      description "调整规则匹配优先级"
      accept [:sequence]
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
    validate compare(:sequence, greater_than: 0)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
