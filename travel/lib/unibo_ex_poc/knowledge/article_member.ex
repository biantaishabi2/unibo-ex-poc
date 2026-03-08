# Workflow: article_member_management — 文章成员权限维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> update
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Knowledge.ArticleMember do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Knowledge,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "文章权限成员，支持个人（partner）和用户组（group）两种授权基准"
  end

  postgres do
    table "knowledge_article_members"
    repo UniboExPoc.Repo
  end

  graphql do
    type :knowledge_article_member

    mutations do
      create :create_knowledge_article_member, :create
      update :update_knowledge_article_member, :update
      destroy :delete_knowledge_article_member, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :based_on, :atom do
      allow_nil? false
      constraints one_of: [:partner, :group]
      public? true
      description "授权基准：partner（个人）或 group（用户组）"
    end
    attribute :permission, :atom do
      allow_nil? false
      constraints one_of: [:read, :write, :owner]
      public? true
      description "权限级别"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :article, UniboExPoc.Knowledge.Article do
      public? true
      allow_nil? false
    end
    belongs_to :partner, UniboExPoc.Knowledge.Party do
      public? true
      source_attribute :partner_party_id
    end
    belongs_to :group, UniboExPoc.Knowledge.Group do
      public? true
    end
  end

  actions do
    defaults [:destroy, :read]
    create :create do
      primary? true
      accept [:article_id, :group_id, :based_on, :permission]
      argument :partner_id, :uuid
      argument :article_id, :uuid, allow_nil?: false
      change manage_relationship(:article_id, :article, type: :append, on_lookup: :relate)
      validate present(:partner_id)
      # message: "based_on=partner 时 partner_id 必填"
      validate present(:group_id)
      # message: "based_on=group 时 group_id 必填"
      validate present([:partner_id, :group_id], exactly: 1)
      # message: "partner_id 和 group_id 不能同时填写"
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:permission]
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
  end

end
