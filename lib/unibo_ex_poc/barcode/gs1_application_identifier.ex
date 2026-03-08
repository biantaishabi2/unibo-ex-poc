# Workflow: gs1_ai_maintain_flow — GS1应用标识符维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Barcode.GS1ApplicationIdentifier do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Barcode,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "GS1应用标识符定义，维护AI编号到数据含义的映射关系（通常为预置数据）"
  end

  postgres do
    table "barcode_gs1_application_identifiers"
    repo UniboV4.Repo
  end

  graphql do
    type :barcode_gs1_application_identifier

    queries do
      get :get_barcode_gs1_application_identifier, :read
      list :list_barcode_gs1_application_identifiers, :read
    end

    mutations do
      create :create_barcode_gs1_application_identifier, :create
      update :update_barcode_gs1_application_identifier, :update
      destroy :delete_barcode_gs1_application_identifier, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :ai_code, :string do
      allow_nil? false
      public? true
      description "AI编号（如\"01\"=GTIN，\"10\"=批号，\"17\"=有效期）"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
      description "标识符名称"
    end
    attribute :data_type, :atom do
      allow_nil? false
      constraints one_of: [:identifier, :alpha, :date, :measure]
      public? true
      description "数据类型"
    end
    attribute :fixed_length, :integer do
      public? true
      description "固定长度（为空表示变长，需FNC1分隔）"
    end
    attribute :max_length, :integer do
      public? true
      description "最大长度（变长字段适用）"
    end
    attribute :pattern, :string do
      public? true
      description "值格式正则表达式"
    end
    attribute :description, :string do
      public? true
      description "标识符详细说明"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    has_many :rules, UniboV4.Barcode.BarcodeRule do
      public? true
      destination_attribute :gs1_ai_id
    end
    has_many :translations, UniboV4.Barcode.GS1ApplicationIdentifierTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:ai_code, :name, :data_type, :fixed_length, :max_length, :pattern, :description]
      validate present(:ai_code)
      validate present(:name)
      validate present(:data_type)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :data_type, :fixed_length, :max_length, :pattern, :description]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_ai_code, [:ai_code]
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
