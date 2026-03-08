# Workflow: app_lifecycle — 应用生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> publish
#   create --> destroy
#   update --> publish
#   update --> destroy
#   publish --> unpublish
#   publish --> update
#   unpublish --> publish
#   unpublish --> update
#   unpublish --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Studio.App do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Studio,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "低代码应用容器，聚合模型/视图/菜单为可发布的应用"
  end

  postgres do
    table "studio_apps"
    repo UniboV4.Repo
  end

  graphql do
    type :studio_app

    queries do
      get :get_studio_app, :read
      list :list_studio_apps, :read
    end

    mutations do
      create :create_studio_app, :create
      update :update_studio_app, :update
      update :publish_studio_app, :publish
      update :unpublish_studio_app, :unpublish
      destroy :delete_studio_app, :destroy
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
      description "应用名称"
    end
    attribute :technical_name, :string do
      allow_nil? false
      public? true
      description "应用技术名"
    end
    attribute :icon, :string do
      public? true
      description "应用图标"
    end
    attribute :color, :string do
      public? true
      description "主题色"
    end
    attribute :description, :string do
      public? true
      description "应用描述"
    end
    attribute :menu_config, :string do
      public? true
      description "菜单树形结构 [{\"label\":\"...\", \"model_id\":N, \"view_type\":\"list\", \"children\":[...]}]"
    end
    attribute :model_ids, :string do
      public? true
      description "包含的模型 ID 列表"
    end
    attribute :published, :boolean do
      default false
      public? true
      description "是否已发布"
    end
    attribute :version, :string do
      public? true
      description "版本号，用于追踪发布版本"
    end
    attribute :access_role_ids, :string do
      public? true
      description "可访问角色 ID 列表，空数组 = 仅创建者可用"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :created_by, UniboV4.Studio.Party do
      public? true
      source_attribute :created_by_party_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :technical_name, :icon, :color, :description, :menu_config, :model_ids, :version, :access_role_ids]
      validate present(:name)
      validate present(:technical_name)
      change relate_actor(:created_by)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :icon, :color, :description, :menu_config, :model_ids, :version, :access_role_ids]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :publish do
      description "发布应用"
      accept []
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:published, true)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :unpublish do
      description "取消发布"
      accept []
      change set_attribute(:published, false)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_technical_name, [:technical_name]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
