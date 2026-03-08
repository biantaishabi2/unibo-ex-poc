defmodule UniboV4.Ofbiz.Marketing.ContactListParty do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "marketing_contact_list_parties"
    repo UniboV4.Repo
  end

  graphql do
    type :marketing_contact_list_party

    queries do
      get :get_marketing_contact_list_party, :read
      list :list_marketing_contact_list_partys, :read
    end

    mutations do
      create :create_marketing_contact_list_party, :create
      update :update_marketing_contact_list_party, :update
      destroy :delete_marketing_contact_list_party, :destroy
    end

  end

  attributes do
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
    attribute :thru_date, :utc_datetime, public?: true
    attribute :status_id, :string, public?: true
    attribute :preferred_contact_mech_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :contact_list, UniboV4.Ofbiz.Marketing.ContactList do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
