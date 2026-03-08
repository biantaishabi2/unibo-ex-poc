defmodule UniboExPoc.Ofbiz.Marketing.WebSiteContactList do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "marketing_web_site_contact_lists"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_web_site_contact_list

    queries do
      get :get_marketing_web_site_contact_list, :read
      list :list_marketing_web_site_contact_lists, :read
    end

    mutations do
      create :create_marketing_web_site_contact_list, :create
      update :update_marketing_web_site_contact_list, :update
      destroy :delete_marketing_web_site_contact_list, :destroy
    end

  end

  attributes do
    attribute :web_site_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :contact_list, UniboExPoc.Ofbiz.Marketing.ContactList do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
