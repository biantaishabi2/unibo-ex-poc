# Workflow: menu_lifecycle — 菜单管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboExPoc.Website.Menu do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Website,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "网站菜单"
  end

  postgres do
    table "website_menus"
    repo UniboExPoc.Repo
  end

  graphql do
    type :website_menu

    queries do
      get :get_website_menu, :read
      list :list_website_menus, :read
    end

    mutations do
      create :create_website_menu, :create
      update :update_website_menu, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "菜单名称（可翻译）"
    end
    attribute :url, :string do
      public? true
      description "菜单链接"
    end
    attribute :parent_path, :string do
      public? true
      description "层级路径（高效查询用）"
    end
    attribute :sequence, :integer do
      default 10
      public? true
      description "排序序号"
    end
    attribute :new_window, :boolean do
      default false
      public? true
      description "新窗口打开"
    end
    attribute :is_mega_menu, :boolean do
      default false
      public? true
      description "是否为 Mega Menu"
    end
    attribute :mega_menu_content, :string do
      public? true
      description "Mega Menu HTML 内容"
    end
    attribute :mega_menu_classes, :string do
      public? true
      description "Mega Menu CSS 类名"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :is_visible, :boolean, expr(url == url)
    calculate :is_active_highlight, :boolean, expr(url == request_url)
    calculate :get_tree, :string, expr(name)
  end

  relationships do
    belongs_to :website, UniboExPoc.Website.WebSite do
      public? true
    end
    belongs_to :page, UniboExPoc.Website.WebPage do
      public? true
    end
    belongs_to :parent, UniboExPoc.Website.Menu do
      public? true
    end
    has_many :children, UniboExPoc.Website.Menu do
      public? true
      source_attribute :parent_id
      destination_attribute :parent_id
    end
    has_many :translations, UniboExPoc.Website.MenuTranslation, public?: true
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :url, :sequence, :new_window, :is_mega_menu, :mega_menu_content, :mega_menu_classes]
      argument :website_id, :uuid
      argument :page_id, :uuid
      argument :parent_id, :uuid
      validate present(:name)
      # validation: max_nesting_two_levels — 菜单最多支持 2 级嵌套
      # validation: mega_menu_no_parent_no_children — Mega Menu 不能有父级也不能有子级
      change UniboExPoc.Website.Changes.Menu.CreateCall1
      change UniboExPoc.Website.Changes.Menu.CreateCall2
      change UniboExPoc.Website.Changes.Menu.CreateCall3
      change UniboExPoc.Website.Changes.Menu.CreateCall4
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
      accept [:name, :url, :sequence, :new_window, :is_mega_menu, :mega_menu_content, :mega_menu_classes]
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change UniboExPoc.Website.Changes.Menu.UpdateCall1
      change UniboExPoc.Website.Changes.Menu.UpdateCall4
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

end
