# Workflow: contact_lifecycle — 联系人管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> update
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.CRM.Contact do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.CRM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "联系人/合作伙伴，CRM 中所有业务关系的核心实体"
  end

  postgres do
    table "crm_contacts"
    repo UniboExPoc.Repo
  end

  graphql do
    type :crm_contact

    queries do
      get :get_crm_contact, :read
      list :list_crm_contacts, :read
    end

    mutations do
      create :create_crm_contact, :create
      update :update_crm_contact, :update
      destroy :delete_crm_contact, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "姓名"
    end
    attribute :email, :string do
      public? true
      description "邮箱，变更时自动通过 mail.thread 追踪记录"
    end
    attribute :phone, :string do
      public? true
      description "固定电话，变更时自动追踪"
    end
    attribute :mobile, :string do
      public? true
      description "手机号，变更时自动追踪"
    end
    attribute :company, :string do
      public? true
      description "公司名称"
    end
    attribute :job_title, :string do
      public? true
      description "职位"
    end
    attribute :contact_type, :atom do
      constraints one_of: [:individual, :company]
      default :individual
      public? true
    end
    attribute :tags, :string do
      public? true
      description "标签（逗号分隔）"
    end
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    has_many :addresses, UniboExPoc.CRM.ContactAddress do
      public? true
    end
    has_many :phones, UniboExPoc.CRM.ContactPhone do
      public? true
    end
    has_many :leads, UniboExPoc.CRM.Lead do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :email, :phone, :mobile, :company, :job_title, :contact_type, :tags, :notes]
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :email, :phone, :mobile, :company, :job_title, :contact_type, :tags, :notes]
      change UniboExPoc.CRM.Changes.Contact.UpdateCall1
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
    archive_related [:addresses, :phones, :leads]
  end

end
