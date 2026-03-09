defmodule UniboExPoc.Marketing.MailingContactListLink do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "群发邮件-邮件列表桥接占位实体"
  end

  postgres do
    table "marketing_mailing_contact_list_links"
    repo UniboExPoc.Repo
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
    belongs_to :mailing, UniboExPoc.Marketing.Mailing do
      public? true
      allow_nil? false
    end
    belongs_to :mailing_list, UniboExPoc.Marketing.MailingList do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
