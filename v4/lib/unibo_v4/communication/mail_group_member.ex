# Workflow: mail_group_member_join_leave_flow — 邮件组成员加入离开流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Communication.MailGroupMember do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Communication,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "communication_mail_group_members"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :email, :string, public?: true
    attribute :email_normalized, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :mail_group, UniboV4.Communication.MailGroup do
      public? true
      allow_nil? false
    end
    belongs_to :partner, UniboV4.Communication.ResPartner do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:email, :email_normalized]
      argument :mail_group_id, :uuid, allow_nil?: false
      argument :partner_id, :uuid
      change manage_relationship(:mail_group_id, :mail_group, type: :append, on_lookup: :relate)
      validate present(:mail_group_id)
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
    identity :unique_partner_per_group, [:partner_id, :mail_group_id]
  end

end
