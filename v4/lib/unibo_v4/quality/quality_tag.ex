# Workflow: quality_tag_maintain_flow — 质量标签维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Quality.QualityTag do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Quality,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "quality_tags"
    repo UniboV4.Repo
  end

  graphql do
    type :quality_quality_tag

    queries do
      get :get_quality_quality_tag, :read
      list :list_quality_quality_tags, :read
    end

    mutations do
      create :create_quality_quality_tag, :create
      update :update_quality_quality_tag, :update
      destroy :delete_quality_quality_tag, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name]
      validate present(:name)
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
      accept [:name]
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
    identity :unique_tag_name, [:name]
  end

end
