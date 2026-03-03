# Workflow: menu_lifecycle — 菜单管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboV4.Ecommerce.Menu do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "ecommerce_menus"
    repo UniboV4.Repo
  end

  graphql do
    type :ecommerce_menu

    queries do
      get :get_ecommerce_menu, :read
      list :list_ecommerce_menus, :read
    end

    mutations do
      create :create_ecommerce_menu, :create
      update :update_ecommerce_menu, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :url, :string, public?: true
    attribute :parent_path, :string, public?: true
    attribute :sequence, :integer do
      default 10
      public? true
    end
    attribute :new_window, :boolean do
      default false
      public? true
    end
    attribute :is_mega_menu, :boolean do
      default false
      public? true
    end
    attribute :mega_menu_content, :string, public?: true
    attribute :mega_menu_classes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :is_visible
    # TODO: 不支持的 calculation 表达式 :is_active_highlight
    # TODO: 不支持的 calculation 表达式 :get_tree
  end

  relationships do
    belongs_to :website, UniboV4.Ecommerce.WebSite do
      public? true
    end
    belongs_to :page, UniboV4.Ecommerce.WebPage do
      public? true
    end
    belongs_to :parent, UniboV4.Ecommerce.Menu do
      public? true
    end
    has_many :children, UniboV4.Ecommerce.Menu do
      public? true
      destination_attribute :parent_id
    end
    has_many :translations, UniboV4.Ecommerce.MenuTranslation, public?: true
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
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 change effect clean_url
      # TODO: 不支持的 change effect auto_copy_to_all_websites
      # TODO: 不支持的 change effect reassign_parent
      # TODO: 不支持的 change effect invalidate_menu_cache
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
      # TODO: 不支持的 change effect clean_url
      # TODO: 不支持的 change effect invalidate_menu_cache
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

end
