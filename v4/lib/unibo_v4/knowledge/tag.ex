# Workflow: tag_management — 标签维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> update
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Knowledge.Tag do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Knowledge,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "knowledge_tags"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :color, :integer, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    many_to_many :articles, UniboV4.Knowledge.Article do
      public? true
      through UniboV4.Knowledge.ArticleTagLink
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :color]
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
      accept [:name, :color]
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
