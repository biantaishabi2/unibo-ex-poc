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
    type :party_party_role

    queries do
      get :get_party_party_role, :read
      list :list_party_party_roles, :read
    end

    mutations do
      create :create_party_party_role, :create
      update :update_party_party_role, :update
      destroy :delete_party_party_role, :destroy
    end

  end

  attributes do
    attribute :party_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
      description "参与方编号"
    end
    attribute :role_type_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
      description "角色类型编号"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :party, UniboExPoc.Ofbiz.Party.Party do
      public? true
      define_attribute? false
    end
    belongs_to :role_type, UniboExPoc.Ofbiz.Party.RoleType do
      public? true
      define_attribute? false
    end
    has_many :role_type_attr, UniboExPoc.Ofbiz.Party.RoleTypeAttr do
      public? true
      source_attribute :role_type_id
      destination_attribute :role_type_id
    end
    has_many :party_attribute, UniboExPoc.Ofbiz.Party.PartyAttribute do
      public? true
      source_attribute :party_id
      destination_attribute :party_id
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
    archive_related [:role_type_attr, :party_attribute]
  end

end
