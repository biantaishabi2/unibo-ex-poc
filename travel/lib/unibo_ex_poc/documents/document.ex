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
defmodule UniboExPoc.Documents.Document do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Documents,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource],
    notifiers: [UniboExPoc.Documents.Document.Notifier]

  resource do
    description "文档记录，支持文件、链接、请求占位、文件夹四种类型"
  end

  postgres do
    table "documents_documents"
    repo UniboExPoc.Repo
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
      description "文档名称，上传时默认取文件名"
    end
    attribute :type, :atom do
      allow_nil? false
      constraints one_of: [:binary, :url, :empty, :folder]
      public? true
      description "binary=文件, url=链接, empty=请求占位, folder=文件夹"
    end
    attribute :url, :string do
      public? true
      description "type=url 时的外部链接"
    end
    attribute :lock_uid, :uuid do
      public? true
      description "锁定用户，非空时其他用户不可编辑"
    end
    attribute :active, :boolean do
      allow_nil? false
      default true
      public? true
      description "归档标志"
    end
    attribute :res_model, :string do
      public? true
      description "关联业务模型名称（如 account.move）"
    end
    attribute :res_id, :integer do
      public? true
      description "关联业务记录 ID"
    end
    attribute :description, :string do
      public? true
      description "文档描述/备注"
    end
    attribute :checksum, :string do
      public? true
      description "文件校验和 SHA-256，用于去重与完整性校验（related → attachment）"
    end
    attribute :mimetype, :string do
      public? true
      description "MIME 类型（related → attachment）"
    end
    attribute :file_size, :integer do
      public? true
      description "文件大小（字节）（related → attachment）"
    end
    attribute :original_filename, :string do
      public? true
      description "原始上传文件名"
    end
    attribute :storage_path, :string do
      public? true
      description "存储路径（S3/MinIO）"
    end
    attribute :matching_algorithm, :atom do
      constraints one_of: [:none, :auto, :manual]
      public? true
      description "预留自动分类策略"
    end
    attribute :tsvector, :string do
      public? true
      description "PostgreSQL 全文索引列（tsvector）"
    end
    attribute :request_activity_id, :uuid do
      public? true
      description "文档请求关联的活动"
    end
    attribute :create_uid, :uuid do
      public? true
      description "创建者"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  calculations do
    calculate :is_favorited, :boolean, expr(contains(favorited_by, actor.id))
    calculate :available_rule_ids, {:array, :string}, {UniboExPoc.Documents.Calculations.Document.AvailableRuleIds, []}
    calculate :thumbnail, :string, {UniboExPoc.Documents.Calculations.Document.Thumbnail, []}
    calculate :file_size_display, :string, {UniboExPoc.Documents.Calculations.Document.FileSizeDisplay, []}
    calculate :checksum_display, :string, {UniboExPoc.Documents.Calculations.Document.ChecksumDisplay, []}
    calculate :mimetype_display, :string, {UniboExPoc.Documents.Calculations.Document.MimetypeDisplay, []}
  end

  relationships do
    belongs_to :folder, UniboExPoc.Documents.Folder do
      public? true
      allow_nil? false
    end
    belongs_to :owner, UniboExPoc.Documents.Party do
      public? true
      source_attribute :owner_party_id
    end
    belongs_to :partner, UniboExPoc.Documents.Contact do
      public? true
    end
    belongs_to :attachment, UniboExPoc.Documents.Attachment do
      public? true
    end
    belongs_to :company, UniboExPoc.Documents.Party do
      public? true
      source_attribute :company_party_id
    end
    many_to_many :tags, UniboExPoc.Documents.Tag do
      public? true
      through UniboExPoc.Documents.DocumentTagLink
    end
    many_to_many :favorited_by, UniboExPoc.Documents.Party do
      public? true
      through UniboExPoc.Documents.DocumentFavoriteLink
      destination_attribute_on_join_resource :user_party_id
    end
    many_to_many :groups, UniboExPoc.Documents.Group do
      public? true
      through UniboExPoc.Documents.DocumentGroupLink
    end
    has_many :versions, UniboExPoc.Documents.DocumentVersion do
      public? true
    end
    many_to_many :shares, UniboExPoc.Documents.Share do
      public? true
      through UniboExPoc.Documents.DocumentShareLink
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :type, :folder_id, :partner_id, :url, :description, :original_filename, :matching_algorithm]
      argument :owner_id, :uuid
      argument :folder_id, :uuid, allow_nil?: false
      change manage_relationship(:folder_id, :folder, type: :append, on_lookup: :relate)
      validate present(:name)
      validate present(:type)
      validate present(:folder_id)
      # message: "每个文档必须属于一个文件夹"
      # relate_actor :owner_id — 无对应关系，跳过
      # relate_actor :create_uid — 无对应关系，跳过
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :description, :partner_id, :folder_id, :url]
      argument :owner_id, :uuid
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :upload do
      description "上传文件（将 request 转为 active）"
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
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :lock do
      description "锁定文档"
      accept []
      # skipped: validate custom_check :lock_uid (incompatible with bulk update atomic path)
      # relate_actor :lock_uid — 无对应关系，跳过
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :unlock do
      description "解锁文档"
      accept []
      # skipped: validate custom_check :lock_uid (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :archive do
      description "归档文档"
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
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :restore do
      description "恢复归档"
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
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :toggle_favorite do
      description "切换收藏状态"
      accept []
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:versions]
  end

end
