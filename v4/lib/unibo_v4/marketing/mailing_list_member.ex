# Workflow: mailing_list_member_lifecycle — 列表成员订阅生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> unsubscribe
#   unsubscribe --> subscribe
#   subscribe --> unsubscribe
# ```
defmodule UniboV4.Marketing.MailingListMember do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "marketing_mailing_list_members"
    repo UniboV4.Repo
  end

  graphql do
    type :marketing_mailing_list_member

    queries do
      get :get_marketing_mailing_list_member, :read
      list :list_marketing_mailing_list_members, :read
    end

    mutations do
      create :create_marketing_mailing_list_member, :create
      update :subscribe_marketing_mailing_list_member, :subscribe
      update :unsubscribe_marketing_mailing_list_member, :unsubscribe
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :email, :string do
      allow_nil? false
      public? true
    end
    attribute :status, :atom do
      constraints one_of: [:subscribed, :unsubscribed]
      default :subscribed
      public? true
    end
    attribute :is_blacklisted, :boolean do
      default false
      public? true
    end
    attribute :message_bounce, :integer do
      default 0
      public? true
    end
    attribute :subscribed_date, :date, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :mailing_list, UniboV4.Marketing.MailingList do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:email, :subscribed_date]
      argument :mailing_list_id, :uuid, allow_nil?: false
      change manage_relationship(:mailing_list_id, :mailing_list, type: :append, on_lookup: :relate)
      validate present(:email)
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
    update :subscribe do
      primary? true
      accept []
      change set_attribute(:status, :subscribed)
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
    update :unsubscribe do
      accept []
      change set_attribute(:status, :unsubscribed)
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
    identity :unique_email_per_list, [:mailing_list_id, :email]
  end

end
