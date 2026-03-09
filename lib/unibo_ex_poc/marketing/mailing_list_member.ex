# Workflow: mailing_list_member_lifecycle — 列表成员订阅生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> unsubscribe
#   unsubscribe --> subscribe
#   subscribe --> unsubscribe
# ```
defmodule UniboExPoc.Marketing.MailingListMember do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "邮件列表成员"
  end

  postgres do
    table "marketing_mailing_list_members"
    repo UniboExPoc.Repo
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
      description "是否黑名单"
    end
    attribute :message_bounce, :integer do
      default 0
      public? true
      description "退信次数"
    end
    attribute :subscribed_date, :date, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :mailing_list, UniboExPoc.Marketing.MailingList do
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
      # validation: public_list_only
      change set_attribute(:id, expr(id))
    end
    update :subscribe do
      description "订阅（重新激活已退订成员）"
      primary? true
      accept []
      change set_attribute(:status, :subscribed)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :unsubscribe do
      description "退订"
      accept []
      change set_attribute(:status, :unsubscribed)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_email_per_list, [:mailing_list_id, :email]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
