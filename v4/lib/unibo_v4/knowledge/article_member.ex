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
defmodule UniboV4.Knowledge.ArticleMember do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Knowledge,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "knowledge_article_members"
    repo UniboV4.Repo
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
    attribute :article_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :partner_id, :uuid, public?: true
    attribute :group_id, :uuid, public?: true
    attribute :based_on, :atom do
      allow_nil? false
      constraints one_of: [:partner, :group]
      public? true
    end
    attribute :permission, :atom do
      allow_nil? false
      constraints one_of: [:read, :write, :owner]
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :article, UniboV4.Knowledge.Article do
      public? true
      allow_nil? false
    end
    belongs_to :partner, UniboV4.Knowledge.User do
      public? true
    end
    belongs_to :group, UniboV4.Knowledge.Group do
      public? true
    end
  end

  actions do
    defaults [:destroy, :read]
    create :create do
      primary? true
      accept [:article_id, :partner_id, :group_id, :based_on, :permission]
      argument :article_id, :uuid, allow_nil?: false
      change manage_relationship(:article_id, :article, type: :append, on_lookup: :relate)
      validate present(:partner_id)
      # message: "based_on=partner 时 partner_id 必填"
      validate present(:group_id)
      # message: "based_on=group 时 group_id 必填"
      # TODO: 不支持的 action 内校验规则 custom
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
      accept [:permission]
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
