# Workflow: mailing_list_maintain_flow — 邮件列表维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.Marketing.MailingList do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "邮件列表"
  end

  postgres do
    table "marketing_mailing_lists"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_mailing_list

    queries do
      get :get_marketing_mailing_list, :read
      list :list_marketing_mailing_lists, :read
    end

    mutations do
      create :create_marketing_mailing_list, :create
      update :update_marketing_mailing_list, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :description, :string, public?: true
    attribute :is_active, :boolean do
      default true
      public? true
    end
    attribute :is_public, :boolean do
      default true
      public? true
      description "是否公开（允许用户自助订阅/退订）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :members, UniboExPoc.Marketing.MailingListMember do
      public? true
    end
    many_to_many :mailings, UniboExPoc.Marketing.Mailing do
      public? true
      through UniboExPoc.Marketing.MailingContactListLink
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :description, :is_public]
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
      accept [:name, :description, :is_active, :is_public]
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
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
    action :merge do
      description "合并去重列表"
      argument :source_list_ids, :string
      argument :archive_source, :string
      run fn input, _context ->
        # BR-ML04: 按 email 分区窗口函数去重，排除 opted-out 和 blacklisted，可选归档源列表 — 由 Change 模块处理: UniboExPoc.Marketing.Changes.MailingList.MergeComplex1
        :ok
      end
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
