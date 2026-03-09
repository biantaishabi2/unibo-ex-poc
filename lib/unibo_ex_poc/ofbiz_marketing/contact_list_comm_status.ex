defmodule UniboExPoc.Ofbiz.Marketing.ContactListCommStatus do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "marketing_contact_list_comm_statuses"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_contact_list_comm_status

    queries do
      get :get_marketing_contact_list_comm_status, :read
      list :list_marketing_contact_list_comm_statuss, :read
    end

    mutations do
      create :create_marketing_contact_list_comm_status, :create
      update :update_marketing_contact_list_comm_status, :update
      destroy :delete_marketing_contact_list_comm_status, :destroy
    end

  end

  attributes do
    attribute :communication_event_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :contact_mech_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :party_id, :string, public?: true
    attribute :message_id, :string, public?: true
    attribute :status_id, :string, public?: true
    attribute :change_by_user_login_id, :string, public?: true
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
