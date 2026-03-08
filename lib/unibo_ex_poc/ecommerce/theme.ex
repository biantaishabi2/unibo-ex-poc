# Workflow: theme_lifecycle — 主题生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> apply
#   update --> update
#   update --> apply
#   apply --> update
#   apply --> switch
#   switch --> apply
# ```
defmodule UniboV4.Ecommerce.Theme do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboV4.Ecommerce.Theme.Notifier]

  resource do
    description "网站主题/配置器"
  end

  postgres do
    table "ecommerce_themes"
    repo UniboV4.Repo
  end

  graphql do
    type :ecommerce_theme

    queries do
      get :get_ecommerce_theme, :read
      list :list_ecommerce_themes, :read
    end

    mutations do
      create :create_ecommerce_theme, :create
      update :update_ecommerce_theme, :update
      update :apply_ecommerce_theme, :apply
      update :switch_ecommerce_theme, :switch
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "主题名称"
    end
    attribute :module_name, :string do
      allow_nil? false
      public? true
      description "对应模块标识"
    end
    attribute :color_palettes, :string do
      public? true
      description "SCSS 颜色定义（JSON）"
    end
    attribute :logo_attachment_id, :uuid do
      public? true
      description "Logo 附件"
    end
    attribute :status, :atom do
      constraints one_of: [:available, :active]
      default :available
      public? true
      description "主题状态"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :website, UniboV4.Ecommerce.WebSite do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :module_name, :color_palettes]
      validate present(:name)
      validate present(:module_name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :color_palettes, :logo_attachment_id]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :apply do
      description "应用主题到网站"
      accept []
      argument :website_id, :uuid, allow_nil?: false
      change set_attribute(:status, :active)
      change set_attribute(:active, false)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :switch do
      description "切换到另一个主题（当前主题变为 available）"
      accept []
      change set_attribute(:status, :available)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
