# Workflow: custom_view_maintain_flow — 自定义视图维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Studio.CustomView do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Studio,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "自定义视图定义，支持 7 种视图类型和拖拽编辑"
  end

  postgres do
    table "studio_custom_views"
    repo UniboExPoc.Repo
  end

  graphql do
    type :studio_custom_view

    queries do
      get :get_studio_custom_view, :read
      list :list_studio_custom_views, :read
    end

    mutations do
      create :create_studio_custom_view, :create
      update :update_studio_custom_view, :update
      destroy :delete_studio_custom_view, :destroy
    end

  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      generated? true
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
      description "视图名称"
    end
    attribute :view_type, :atom do
      allow_nil? false
      constraints one_of: [:form, :list, :kanban, :calendar, :pivot, :graph, :gallery]
      public? true
      description "视图类型，共 7 种"
    end
    attribute :arch, :string do
      allow_nil? false
      public? true
      description "视图定义（JSON Schema），结构因 view_type 而异"
    end
    attribute :is_default, :boolean do
      default false
      public? true
      description "该类型的默认视图"
    end
    attribute :sequence, :integer do
      public? true
      description "同类型视图排序"
    end
    attribute :filters_config, :string do
      public? true
      description "预设筛选条件（Domain 表达式语法）"
    end
    attribute :sorts_config, :string do
      public? true
      description "预设排序配置"
    end
    attribute :group_by_config, :string do
      public? true
      description "预设分组配置"
    end
    attribute :permission_level, :atom do
      constraints one_of: [:collaborative, :locked, :personal]
      default :collaborative
      public? true
      description "视图权限级别"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :model, UniboExPoc.Studio.CustomModel do
      public? true
      allow_nil? false
      attribute_type :integer
    end
    belongs_to :created_by, UniboExPoc.Studio.Party do
      public? true
      source_attribute :created_by_party_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :view_type, :arch, :is_default, :sequence, :filters_config, :sorts_config, :group_by_config, :permission_level]
      argument :model_id, :integer, allow_nil?: false
      change manage_relationship(:model_id, :model, type: :append, on_lookup: :relate)
      validate present(:name)
      validate present(:view_type)
      validate present(:arch)
      change relate_actor(:created_by)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :arch, :is_default, :sequence, :filters_config, :sorts_config, :group_by_config, :permission_level]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_model_view_type_name, [:model_id, :view_type, :name]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
