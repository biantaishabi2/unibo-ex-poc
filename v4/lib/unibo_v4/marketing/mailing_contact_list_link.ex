defmodule UniboV4.Marketing.MailingContactListLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "marketing_mailing_contact_list_links"
    repo UniboV4.Repo
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
    defaults [:read]
  end

end
