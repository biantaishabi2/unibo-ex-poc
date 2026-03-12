defmodule UniboExPoc.Ofbiz.Party.PartyRole do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "party_roles"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_party_party_role

    queries do
      get :get_ofbiz_party_party_role, :read
      list :list_ofbiz_party_party_roles, :read
    end

    mutations do
      create :create_ofbiz_party_party_role, :create
      update :update_ofbiz_party_party_role, :update
      destroy :delete_ofbiz_party_party_role, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :party, UniboExPoc.Ofbiz.Party.Party do
      public? true
    end
    belongs_to :role_type_ref, UniboExPoc.Ofbiz.Party.RoleType do
      public? true
      source_attribute :role_type_id
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
