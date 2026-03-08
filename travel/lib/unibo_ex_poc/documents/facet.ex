# Workflow: facet_lifecycle_flow — 标签分类创建、编辑与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.Documents.Facet do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Documents,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "标签分类（如\"状态\"、\"部门\"、\"优先级\"），归属于 Folder/Workspace"
  end

  postgres do
    table "documents_facets"
    repo UniboExPoc.Repo
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
      description "分类名称（如\"状态\"、\"部门\"、\"优先级\"）"
    end
    attribute :sequence, :integer do
      public? true
      description "显示排序"
    end
    attribute :tooltip, :string do
      public? true
      description "鼠标悬停提示文字"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :folder, UniboExPoc.Documents.Folder do
      public? true
      allow_nil? false
    end
    has_many :tags, UniboExPoc.Documents.Tag do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :folder_id, :sequence, :tooltip]
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
      description "删除 Facet 时级联删除其下所有 Tag"
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:tags]
  end

end
