# Workflow: mailing_list_maintain_flow — 邮件列表维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.Marketing.MailingList do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "marketing_mailing_lists"
    repo UniboV4.Repo
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
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :members, UniboV4.Marketing.MailingListMember do
      public? true
    end
    many_to_many :mailings, UniboV4.Marketing.Mailing do
      public? true
      through UniboV4.Marketing.MailingContactListLink
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
    action :merge do
      argument :source_list_ids, :string
      argument :archive_source, :string
      # TODO: generic action 不支持 change，需要用 run
    end
  end

end
