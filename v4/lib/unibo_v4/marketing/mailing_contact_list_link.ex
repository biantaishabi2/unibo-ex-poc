defmodule UniboV4.Marketing.MailingContactListLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "marketing_mailing_contact_list_links"
    repo UniboV4.Repo
  end

  graphql do
    type :marketing_mailing_contact_list_link

    queries do
      get :get_marketing_mailing_contact_list_link, :read
      list :list_marketing_mailing_contact_list_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :mailing, UniboV4.Marketing.Mailing do
      public? true
      allow_nil? false
    end
    belongs_to :mailing_list, UniboV4.Marketing.MailingList do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
