defmodule UniboExPoc.Ofbiz.Marketing.ContactListPartyStatus do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "marketing_contact_list_party_statuses"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_contact_list_party_status

    queries do
      get :get_marketing_contact_list_party_status, :read
      list :list_marketing_contact_list_party_statuss, :read
    end

    mutations do
      create :create_marketing_contact_list_party_status, :create
      update :update_marketing_contact_list_party_status, :update
      destroy :delete_marketing_contact_list_party_status, :destroy
    end

  end

  attributes do
    attribute :contact_list_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :status_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :status_id, :string, public?: true
    attribute :set_by_user_login_id, :string, public?: true
    attribute :opt_in_verify_code, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
