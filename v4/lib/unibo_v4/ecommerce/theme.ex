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
    otp_app: :unibo_v4,
    domain: UniboV4.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Ecommerce.Theme.Notifier]

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
    end
    attribute :module_name, :string do
      allow_nil? false
      public? true
    end
    attribute :color_palettes, :string, public?: true
    attribute :logo_attachment_id, :uuid, public?: true
    attribute :status, :atom do
      constraints one_of: [:available, :active]
      default :available
      public? true
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
      accept [:name, :color_palettes, :logo_attachment_id]
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
    update :apply do
      accept []
      argument :website_id, :uuid, allow_nil?: false
      change set_attribute(:status, :active)
      # TODO: 不支持的 change effect deactivate_previous_theme
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
    update :switch do
      accept []
      change set_attribute(:status, :available)
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
