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
    otp_app: :unibo_v4,
    domain: UniboV4.Studio,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "studio_apps"
    repo UniboV4.Repo
  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :technical_name, :string do
      allow_nil? false
      public? true
    end
    attribute :icon, :string, public?: true
    attribute :color, :string, public?: true
    attribute :description, :string, public?: true
    attribute :menu_config, :string, public?: true
    attribute :model_ids, :string, public?: true
    attribute :published, :boolean do
      default false
      public? true
    end
    attribute :version, :string, public?: true
    attribute :access_role_ids, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :created_by, UniboV4.Studio.User do
      public? true
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
      accept [:name, :icon, :color, :description, :menu_config, :model_ids, :version, :access_role_ids]
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
    update :publish do
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:published, true)
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
    update :unpublish do
      accept []
      change set_attribute(:published, false)
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

  identities do
    identity :unique_technical_name, [:technical_name]
  end

end
