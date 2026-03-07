defmodule UniboExPoc.Ofbiz.Party.PartyIdentification do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "party_identifications"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_party_identification

    queries do
      get :get_party_party_identification, :read
      list :list_party_party_identifications, :read
    end

    mutations do
      create :create_party_party_identification, :create
      update :update_party_party_identification, :update
      destroy :delete_party_party_identification, :destroy
    end

  end

  attributes do
    attribute :party_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
      description "参与方编号"
    end
    attribute :party_identification_type_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
      description "参与方标识类型编号"
    end
    attribute :id_value, :string do
      public? true
      description "编号值"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :party_identification_type, UniboExPoc.Ofbiz.Party.PartyIdentificationType do
      public? true
      define_attribute? false
    end
    belongs_to :party, UniboExPoc.Ofbiz.Party.Party do
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
