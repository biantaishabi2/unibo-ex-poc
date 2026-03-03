# Workflow: document_lifecycle_flow — 文档从创建到上传、锁定、归档与恢复的完整生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   upload --> [*]
#   lock --> [*]
#   unlock --> [*]
#   archive --> [*]
#   restore --> [*]
#   update --> [*]
#   toggle_favorite --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Documents.Document do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Documents,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Documents.Document.Notifier]

  postgres do
    table "documents_documents"
    repo UniboV4.Repo
  end

  graphql do
    type :documents_document

    queries do
      get :get_documents_document, :read
      list :list_documents_documents, :read
    end

    mutations do
      create :create_documents_document, :create
      update :update_documents_document, :update
      update :upload_documents_document, :upload
      update :lock_documents_document, :lock
      update :unlock_documents_document, :unlock
      update :archive_documents_document, :archive
      update :restore_documents_document, :restore
      update :toggle_favorite_documents_document, :toggle_favorite
      destroy :delete_documents_document, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :type, :atom do
      allow_nil? false
      constraints one_of: [:binary, :url, :empty, :folder]
      public? true
    end
    attribute :folder_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :owner_id, :uuid, public?: true
    attribute :partner_id, :uuid, public?: true
    attribute :attachment_id, :uuid, public?: true
    attribute :url, :string, public?: true
    attribute :lock_uid, :uuid, public?: true
    attribute :active, :boolean do
      allow_nil? false
      default true
      public? true
    end
    attribute :company_id, :uuid, public?: true
    attribute :res_model, :string, public?: true
    attribute :res_id, :integer, public?: true
    attribute :description, :string, public?: true
    attribute :checksum, :string, public?: true
    attribute :mimetype, :string, public?: true
    attribute :file_size, :integer, public?: true
    attribute :original_filename, :string, public?: true
    attribute :storage_path, :string, public?: true
    attribute :matching_algorithm, :atom do
      constraints one_of: [:none, :auto, :manual]
      public? true
    end
    attribute :tsvector, :string, public?: true
    attribute :request_activity_id, :uuid, public?: true
    attribute :create_uid, :uuid, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :is_favorited
    # TODO: 不支持的 calculation 表达式 :available_rule_ids
    # TODO: 不支持的 calculation 表达式 :thumbnail
    # TODO: 不支持的 calculation 表达式 :file_size_display
    # TODO: 不支持的 calculation 表达式 :checksum_display
    # TODO: 不支持的 calculation 表达式 :mimetype_display
  end

  relationships do
    belongs_to :folder, UniboV4.Documents.Document do
      public? true
      allow_nil? false
    end
    belongs_to :owner, UniboV4.Documents.User do
      public? true
    end
    belongs_to :partner, UniboV4.Documents.Contact do
      public? true
    end
    belongs_to :attachment, UniboV4.Documents.Attachment do
      public? true
    end
    belongs_to :company, UniboV4.Documents.Company do
      public? true
    end
    many_to_many :tags, UniboV4.Documents.Tag do
      public? true
      through UniboV4.Documents.DocumentTagLink
    end
    many_to_many :favorited_by, UniboV4.Documents.User do
      public? true
      through UniboV4.Documents.DocumentFavoriteLink
    end
    many_to_many :groups, UniboV4.Documents.Group do
      public? true
      through UniboV4.Documents.DocumentGroupLink
    end
    has_many :versions, UniboV4.Documents.DocumentVersion do
      public? true
    end
    many_to_many :shares, UniboV4.Documents.Share do
      public? true
      through UniboV4.Documents.DocumentShareLink
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :type, :folder_id, :owner_id, :partner_id, :url, :description, :original_filename, :matching_algorithm]
      argument :folder_id, :uuid, allow_nil?: false
      change manage_relationship(:folder_id, :folder, type: :append, on_lookup: :relate)
      validate present(:name)
      validate present(:type)
      validate present(:folder_id)
      # message: "每个文档必须属于一个文件夹"
      change relate_actor(:owner_id)
      change relate_actor(:create_uid)
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
      accept [:name, :description, :partner_id, :owner_id, :folder_id, :url]
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
    update :upload do
      accept [:attachment_id, :original_filename]
      # skipped: validate present :attachment_id (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :type)
        if current == :empty do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :type, message: "must equal %{value}", vars: %{value: :empty}))
        end
      end
      # message: "只有请求占位文档可以执行上传"
      change set_attribute(:type, :binary)
      change set_attribute(:active, true)
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
    update :lock do
      accept []
      # skipped: validate custom :lock_uid (incompatible with bulk update atomic path)
      change relate_actor(:lock_uid)
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
    update :unlock do
      accept []
      # skipped: validate custom :lock_uid (incompatible with bulk update atomic path)
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
    update :archive do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :active)
        if current == true do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :active, message: "must equal %{value}", vars: %{value: true}))
        end
      end
      # message: "只有活跃文档可以归档"
      change set_attribute(:active, false)
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
    update :restore do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :active)
        if current == false do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :active, message: "must equal %{value}", vars: %{value: false}))
        end
      end
      # message: "只有已归档文档可以恢复"
      change set_attribute(:active, true)
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
    update :toggle_favorite do
      accept []
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
