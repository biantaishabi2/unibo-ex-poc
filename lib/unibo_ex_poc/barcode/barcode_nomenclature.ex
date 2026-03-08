# Workflow: nomenclature_lifecycle — 命名法生命周期管理
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> activate
#   create --> deactivate
#   create --> destroy
#   update --> activate
#   update --> deactivate
#   update --> destroy
#   activate --> update
#   activate --> deactivate
#   deactivate --> update
#   deactivate --> activate
#   deactivate --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Barcode.BarcodeNomenclature do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Barcode,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "条码命名法，定义一套解析规则集，支持普通条码和GS1-128模式"
  end

  postgres do
    table "barcode_nomenclatures"
    repo UniboV4.Repo
  end

  graphql do
    type :barcode_barcode_nomenclature

    queries do
      get :get_barcode_barcode_nomenclature, :read
      list :list_barcode_barcode_nomenclatures, :read
    end

    mutations do
      create :create_barcode_barcode_nomenclature, :create
      update :update_barcode_barcode_nomenclature, :update
      update :activate_barcode_barcode_nomenclature, :activate
      update :deactivate_barcode_barcode_nomenclature, :deactivate
      destroy :delete_barcode_barcode_nomenclature, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "命名法名称"
    end
    attribute :description, :string do
      public? true
      description "命名法描述"
    end
    attribute :is_gs1_compliant, :boolean do
      default false
      public? true
      description "是否启用GS1解析模式（对齐Odoo is_gs1_nomenclature）"
    end
    attribute :upc_ean_conv, :atom do
      constraints one_of: [:none, :ean2upc, :upc2ean, :always]
      default :none
      public? true
      description "UPC/EAN互转模式"
    end
    attribute :gs1_separator_fnc1, :string do
      default "(Alt029|#|\x1D)"
      public? true
      description "GS1 FNC1分隔符替代正则（is_gs1_compliant=true时使用）"
    end
    attribute :active, :boolean do
      default true
      public? true
      description "是否启用"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    has_many :rules, UniboV4.Barcode.BarcodeRule do
      public? true
      destination_attribute :nomenclature_id
    end
    has_many :translations, UniboV4.Barcode.BarcodeNomenclatureTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :description, :is_gs1_compliant, :upc_ean_conv, :gs1_separator_fnc1, :active]
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :description, :is_gs1_compliant, :upc_ean_conv, :gs1_separator_fnc1, :active]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :activate do
      description "启用命名法"
      accept []
      change UniboV4.Barcode.Changes.BarcodeNomenclature.ComputeActive
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :deactivate do
      description "停用命名法"
      accept []
      change UniboV4.Barcode.Changes.BarcodeNomenclature.ComputeActive
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:rules]
  end

end
