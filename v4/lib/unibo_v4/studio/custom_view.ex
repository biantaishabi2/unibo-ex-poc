# Workflow: custom_view_maintain_flow — 自定义视图维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Studio.CustomView do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Studio,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "studio_custom_views"
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
    attribute :view_type, :atom do
      allow_nil? false
      constraints one_of: [:form, :list, :kanban, :calendar, :pivot, :graph, :gallery]
      public? true
    end
    attribute :arch, :string do
      allow_nil? false
      public? true
    end
    attribute :is_default, :boolean do
      default false
      public? true
    end
    attribute :sequence, :integer, public?: true
    attribute :filters_config, :string, public?: true
    attribute :sorts_config, :string, public?: true
    attribute :group_by_config, :string, public?: true
    attribute :permission_level, :atom do
      constraints one_of: [:collaborative, :locked, :personal]
      default :collaborative
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :model, UniboV4.Studio.CustomModel do
      public? true
      allow_nil? false
      attribute_type :integer
    end
    belongs_to :created_by, UniboV4.Studio.User do
      public? true
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
      accept [:name, :arch, :is_default, :sequence, :filters_config, :sorts_config, :group_by_config, :permission_level]
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
    identity :unique_model_view_type_name, [:model_id, :view_type, :name]
  end

end
