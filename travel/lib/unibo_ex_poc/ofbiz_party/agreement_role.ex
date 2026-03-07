defmodule UniboExPoc.Ofbiz.Party.AgreementRole do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "party_agreement_roles"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_agreement_role

    queries do
      get :get_party_agreement_role, :read
      list :list_party_agreement_roles, :read
    end

    mutations do
      create :create_party_agreement_role, :create
      update :update_party_agreement_role, :update
      destroy :delete_party_agreement_role, :destroy
    end

  end

  attributes do
    attribute :agreement_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
      description "协议编号"
    end
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
    belongs_to :agreement, UniboExPoc.Ofbiz.Party.Agreement do
      public? true
      define_attribute? false
    end
    belongs_to :party, UniboExPoc.Ofbiz.Party.Party do
      public? true
      define_attribute? false
    end
    belongs_to :role_type, UniboExPoc.Ofbiz.Party.RoleType do
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
