# Workflow: share_lifecycle_flow — 分享链接创建、更新、上传与失效流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   upload_via_share --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Documents.Share do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Documents,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "documents_shares"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
    attribute :type, :atom do
      allow_nil? false
      constraints one_of: [:ids, :domain]
      public? true
    end
    attribute :access_token, :string, public?: true
    attribute :date_deadline, :date, public?: true
    attribute :action, :atom do
      allow_nil? false
      constraints one_of: [:download, :download_upload]
      public? true
    end
    attribute :email_drop, :boolean do
      default false
      public? true
    end
    attribute :activity_option, :atom do
      constraints one_of: [:nothing, :mark_done, :schedule]
      public? true
    end
    attribute :base_url, :string, public?: true
    attribute :create_uid, :uuid, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :full_url
    # TODO: 不支持的 calculation 表达式 :state
  end

  relationships do
    belongs_to :folder, UniboV4.Documents.Document do
      public? true
    end
    many_to_many :documents, UniboV4.Documents.Document do
      public? true
      through UniboV4.Documents.DocumentShareLink
    end
    many_to_many :tags, UniboV4.Documents.Tag do
      public? true
      through UniboV4.Documents.ShareTagLink
    end
    belongs_to :partner, UniboV4.Documents.Contact do
      public? true
    end
    belongs_to :owner, UniboV4.Documents.User do
      public? true
    end
    belongs_to :alias, UniboV4.Documents.MailAlias do
      public? true
    end
    belongs_to :creator, UniboV4.Documents.User do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :type, :date_deadline, :action, :email_drop, :activity_option]
      argument :document_ids, {:array, :string}
      validate present(:type)
      validate present(:action)
      validate present(:folder_id)
      # message: "type=domain 时必须指定文件夹"
      validate present(:document_ids)
      # message: "type=ids 时必须指定文档列表"
      # relate_actor :create_uid — 无对应关系，跳过
      # TODO: 跨实体聚合表达式暂不支持
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
      accept [:name, :date_deadline, :action, :email_drop, :activity_option]
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
    read :access do
      argument :access_token, :string, allow_nil?: false
    end
    create :upload_via_share do
      accept []
      argument :access_token, :string, allow_nil?: false
      argument :file, :string, allow_nil?: false
      validate present(:type)
      validate present(:action)
      validate present(:folder_id)
      # message: "type=domain 时必须指定文件夹"
      # skipped: validate present(:document_ids) — field not found
      # relate_actor :create_uid — 无对应关系，跳过
      # TODO: 跨实体聚合表达式暂不支持
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
    identity :unique_access_token, [:access_token]
  end

end
