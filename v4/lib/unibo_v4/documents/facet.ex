# Workflow: facet_lifecycle_flow — 标签分类创建、编辑与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Documents.Facet do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Documents,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "documents_facets"
    repo UniboV4.Repo
  end

  graphql do
    type :documents_facet

    queries do
      get :get_documents_facet, :read
      list :list_documents_facets, :read
    end

    mutations do
      create :create_documents_facet, :create
      update :update_documents_facet, :update
      destroy :delete_documents_facet, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :sequence, :integer, public?: true
    attribute :tooltip, :string, public?: true
  end

  relationships do
    belongs_to :folder, UniboV4.Documents.Document do
      public? true
      allow_nil? false
    end
    has_many :tags, UniboV4.Documents.Tag do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :sequence, :tooltip]
      argument :folder_id, :uuid, allow_nil?: false
      change manage_relationship(:folder_id, :folder, type: :append, on_lookup: :relate)
      validate present(:name)
      validate present(:folder_id)
      # message: "每个 Facet 必须关联到一个文件夹"
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
      accept [:name, :sequence, :tooltip]
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
    destroy :destroy do
      primary? true
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
  end

  identities do
    identity :unique_facet_name_per_folder, [:folder_id, :name]
  end

end
