defmodule UniboV4.Marketing.MailingListMember do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "mailing_list_members"
    repo UniboV4.Repo
  end

  graphql do
    type :mailing_list_member

    queries do
      get :get_mailing_list_member, :read
      list :list_mailing_list_members, :read
    end

    mutations do
      create :create_mailing_list_member, :create
      update :unsubscribe_mailing_list_member, :unsubscribe
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :email, :string, allow_nil?: false, public?: true
    attribute :status, :atom do
      constraints one_of: [:subscribed, :unsubscribed]
      default :subscribed
        public? true
    end
    attribute :subscribed_date, :date, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :mailing_list, UniboV4.Marketing.MailingList do
      allow_nil? false
        public? true
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
    end
    update :unsubscribe do
      accept []
      change set_attribute(:status, :unsubscribed)
    end
  end

end
