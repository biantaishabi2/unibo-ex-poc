# Workflow: mail_group_member_join_leave_flow — 邮件组成员加入离开流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Communication.MailGroupMember do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Communication,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "邮件组成员——记录用户在邮件组中的订阅关系"
  end

  postgres do
    table "communication_mail_group_members"
    repo UniboV4.Repo
  end

  graphql do
    type :communication_mail_group_member

    queries do
      get :get_communication_mail_group_member, :read
      list :list_communication_mail_group_members, :read
    end

    mutations do
      create :create_communication_mail_group_member, :create
      destroy :delete_communication_mail_group_member, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :email, :string do
      public? true
      description "成员邮箱（从 partner 同步）"
    end
    attribute :email_normalized, :string do
      public? true
      description "标准化邮箱地址"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :mail_group, UniboV4.Communication.MailGroup do
      public? true
      allow_nil? false
    end
    belongs_to :partner, UniboV4.Communication.Party do
      public? true
      source_attribute :partner_party_id
    end
  end

  actions do
    defaults [:read, :destroy, :update]
    create :create do
      primary? true
      accept [:email, :email_normalized]
      argument :mail_group_id, :uuid, allow_nil?: false
      argument :partner_id, :uuid
      change manage_relationship(:mail_group_id, :mail_group, type: :append, on_lookup: :relate)
      validate present(:mail_group_id)
      change set_attribute(:id, expr(id))
    end
  end

  identities do
    identity :unique_partner_per_group, [:partner_id, :mail_group_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
