defmodule Travel.Travel.TravelStaticCodeMapping do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: Travel.Travel,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "供应商静态码到 Travel 主数据的映射（Travel 层统一适配）"
  end

  postgres do
    table "travel_static_code_mappings"
    repo Travel.Repo
    identity_index_names unique_supplier_static_code: "idx_travel_static_code_mappings_unique_supplier_static_code"
  end

  graphql do
    type :travel_travel_static_code_mapping

    queries do
      get :get_travel_travel_static_code_mapping, :read
      list :list_travel_travel_static_code_mappings, :read
    end

    mutations do
      create :create_travel_travel_static_code_mapping, :create
      update :update_travel_travel_static_code_mapping, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :supplier_code, :string do
      allow_nil? false
      public? true
      description "供应商编码"
    end
    attribute :object_type, :atom do
      allow_nil? false
      constraints one_of: [:city, :airport, :station, :hotel, :room_type, :airline, :cabin_class]
      public? true
      description "主数据对象类型"
    end
    attribute :canonical_entity, :string do
      allow_nil? false
      public? true
      description "Travel 实体名"
    end
    attribute :canonical_id, :uuid do
      allow_nil? false
      public? true
      description "Travel 实体 ID"
    end
    attribute :external_code, :string do
      allow_nil? false
      public? true
      description "供应商侧编码"
    end
    attribute :external_name, :string do
      public? true
      description "供应商侧名称"
    end
    attribute :status, :atom do
      constraints one_of: [:active, :inactive]
      default :active
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Travel Static Code Mapping via Create. doc_url: graphql://contract/travel/create_travel_travel_static_code_mapping"
      primary? true
      accept [:supplier_code, :object_type, :canonical_entity, :canonical_id, :external_code, :external_name, :status]
    end
    update :update do
      description "Update Travel Static Code Mapping via Update. doc_url: graphql://contract/travel/update_travel_travel_static_code_mapping"
      primary? true
      accept [:canonical_entity, :canonical_id, :external_name, :status]
      require_atomic? false
    end
  end

  identities do
    identity :unique_supplier_static_code, [:supplier_code, :object_type, :external_code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    belongs_to_actor :user, Travel.Accounts.User, allow_nil?: true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
