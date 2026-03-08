# Workflow: share_lifecycle_flow — 分享链接创建、更新、上传与失效流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   upload_via_share --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.Documents.Share do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Documents,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "文档分享链接，支持指定文档或按文件夹分享"
  end

  postgres do
    table "documents_shares"
    repo UniboExPoc.Repo
  end

  graphql do
    type :documents_share

    queries do
      get :get_documents_share, :read
      list :list_documents_shares, :read
      get :get_access_documents_share, :access
      list :list_access_documents_shares, :access
    end

    mutations do
      create :create_create_documents_share, :create
      create :create_upload_via_share_documents_share, :upload_via_share
      update :update_documents_share, :update
      destroy :delete_documents_share, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      public? true
      description "分享名称/标题"
    end
    attribute :type, :atom do
      allow_nil? false
      constraints one_of: [:ids, :domain]
      public? true
      description "ids=指定文档, domain=文件夹/条件"
    end
    attribute :access_token, :string do
      public? true
      description "UUID v4 生成的 URL 访问令牌"
    end
    attribute :date_deadline, :date do
      public? true
      description "分享链接过期日期"
    end
    attribute :action, :atom do
      allow_nil? false
      constraints one_of: [:download, :download_upload]
      public? true
      description "download=仅下载, download_upload=下载+上传"
    end
    attribute :email_drop, :boolean do
      default false
      public? true
      description "是否启用邮件上传"
    end
    attribute :activity_option, :atom do
      constraints one_of: [:nothing, :mark_done, :schedule]
      public? true
      description "上传文档时的活动处理"
    end
    attribute :base_url, :string do
      public? true
      description "网站根 URL（用于拼接分享链接）"
    end
    attribute :create_uid, :uuid do
      public? true
      description "分享创建者"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  calculations do
    calculate :full_url, :string, expr(base_url <> "/document/share/" <> id <> "/" <> access_token)
    calculate :state, :atom, expr(if((date_deadline == nil or date_deadline >= today()), :live, :expired))
  end

  relationships do
    belongs_to :folder, UniboExPoc.Documents.Document do
      public? true
    end
    many_to_many :documents, UniboExPoc.Documents.Document do
      public? true
      through UniboExPoc.Documents.DocumentShareLink
    end
    many_to_many :tags, UniboExPoc.Documents.Tag do
      public? true
      through UniboExPoc.Documents.ShareTagLink
    end
    belongs_to :partner, UniboExPoc.Documents.Contact do
      public? true
    end
    belongs_to :owner, UniboExPoc.Documents.Party do
      public? true
      source_attribute :owner_party_id
    end
    belongs_to :alias, UniboExPoc.Documents.MailAlias do
      public? true
    end
    belongs_to :creator, UniboExPoc.Documents.Party do
      public? true
      source_attribute :creator_party_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :type, :folder_id, :date_deadline, :action, :partner_id, :email_drop, :activity_option]
      argument :owner_id, :uuid
      argument :document_ids, {:array, :string}
      validate present(:type)
      validate present(:action)
      validate present(:folder_id)
      # message: "type=domain 时必须指定文件夹"
      # relate_actor :create_uid — 无对应关系，跳过
      change UniboExPoc.Documents.Changes.Share.ComputeAccessToken
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :date_deadline, :action, :partner_id, :email_drop, :activity_option]
      argument :owner_id, :uuid
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    read :access do
      description "通过 access_token 访问分享内容"
      argument :access_token, :string, allow_nil?: false
    end
    create :upload_via_share do
      description "通过分享链接上传文档"
      accept []
      argument :access_token, :string, allow_nil?: false
      argument :file, :string, allow_nil?: false
      validate present(:type)
      validate present(:action)
      validate present(:folder_id)
      # message: "type=domain 时必须指定文件夹"
      # relate_actor :create_uid — 无对应关系，跳过
      change UniboExPoc.Documents.Changes.Share.ComputeAccessToken
      change set_attribute(:id, expr(id))
    end
  end

  identities do
    identity :unique_access_token, [:access_token]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
