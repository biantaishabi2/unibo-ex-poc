defmodule UniboExPoc.Ofbiz.Party.ValidContactMechRole do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "party_valid_contact_mech_roles"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_valid_contact_mech_role

    queries do
      get :get_party_valid_contact_mech_role, :read
      list :list_party_valid_contact_mech_roles, :read
    end

    mutations do
      create :create_party_valid_contact_mech_role, :create
      update :update_party_valid_contact_mech_role, :update
      destroy :delete_party_valid_contact_mech_role, :destroy
    end

  end

  attributes do
    attribute :role_type_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
      description "角色类型编号"
    end
    attribute :contact_mech_type_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
      description "联系方式类型编号"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :role_type, UniboExPoc.Ofbiz.Party.RoleType do
      public? true
      define_attribute? false
    end
    belongs_to :contact_mech_type, UniboExPoc.Ofbiz.Party.ContactMechType do
      public? true
      define_attribute? false
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
