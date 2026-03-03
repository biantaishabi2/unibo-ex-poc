# Workflow: tag_lifecycle_flow — 标签创建、编辑与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Documents.Tag do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Documents,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "documents_tags"
    repo UniboV4.Repo
  end

  graphql do
    type :documents_tag

    queries do
      get :get_documents_tag, :read
      list :list_documents_tags, :read
    end

    mutations do
      create :create_documents_tag, :create
      update :update_documents_tag, :update
      destroy :delete_documents_tag, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :facet_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :sequence, :integer, public?: true
    attribute :color, :integer, public?: true
  end

  relationships do
    belongs_to :facet, UniboV4.Documents.Facet do
      public? true
      allow_nil? false
    end
    many_to_many :documents, UniboV4.Documents.Document do
      public? true
      through UniboV4.Documents.DocumentTagLink
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :facet_id, :sequence, :color]
      argument :facet_id, :uuid, allow_nil?: false
      change manage_relationship(:facet_id, :facet, type: :append, on_lookup: :relate)
      validate present(:name)
      validate present(:facet_id)
      # message: "每个 Tag 必须属于一个 Facet"
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
      accept [:name, :sequence, :color]
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
    identity :unique_tag_name_per_facet, [:facet_id, :name]
  end

end
