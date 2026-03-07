defmodule UniboExPoc.Ofbiz.Party.PartyTypeAttr do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "party_type_attrs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_party_type_attr

    queries do
      get :get_party_party_type_attr, :read
      list :list_party_party_type_attrs, :read
    end

    mutations do
      create :create_party_party_type_attr, :create
      update :update_party_party_type_attr, :update
      destroy :delete_party_party_type_attr, :destroy
    end

  end

  attributes do
    attribute :party_type_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
      description "参与方类型编号"
    end
    attribute :attr_name, :string do
      allow_nil? false
      primary_key? true
      public? true
      description "属性名"
    end
    attribute :description, :string do
      public? true
      description "说明"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :party_type, UniboExPoc.Ofbiz.Party.PartyType do
      public? true
      define_attribute? false
    end
    has_many :party, UniboExPoc.Ofbiz.Party.Party do
      public? true
      source_attribute :party_type_id
      destination_attribute :party_type_id
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
    archive_related [:party]
  end

end
