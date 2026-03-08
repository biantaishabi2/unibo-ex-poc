# Workflow: mail_group_moderation_rule_flow — 邮件组审核规则维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.Communication.MailGroupModeration do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Communication,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "邮件组审核规则——按邮箱地址设置白名单/黑名单"
  end

  postgres do
    table "communication_mail_group_moderations"
    repo UniboExPoc.Repo
  end

  graphql do
    type :communication_mail_group_moderation

    queries do
      get :get_communication_mail_group_moderation, :read
      list :list_communication_mail_group_moderations, :read
    end

    mutations do
      create :create_communication_mail_group_moderation, :create
      update :update_communication_mail_group_moderation, :update
      destroy :delete_communication_mail_group_moderation, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :email, :string do
      allow_nil? false
      public? true
      description "邮箱地址"
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:allow, :ban]
      public? true
      description "审核状态；allow 白名单，ban 黑名单"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :mail_group, UniboExPoc.Communication.MailGroup do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:email, :status]
      argument :mail_group_id, :uuid, allow_nil?: false
      change manage_relationship(:mail_group_id, :mail_group, type: :append, on_lookup: :relate)
      validate present(:email)
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
      accept [:status]
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
  end

  identities do
    identity :unique_email_per_group, [:email, :mail_group_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
