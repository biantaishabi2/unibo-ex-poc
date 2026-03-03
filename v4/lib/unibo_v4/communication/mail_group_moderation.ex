# Workflow: mail_group_moderation_rule_flow — 邮件组审核规则维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Communication.MailGroupModeration do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Communication,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "communication_mail_group_moderations"
    repo UniboV4.Repo
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
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:allow, :ban]
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :mail_group, UniboV4.Communication.MailGroup do
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
      # skipped: validate custom : (incompatible with bulk update atomic path)
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

end
