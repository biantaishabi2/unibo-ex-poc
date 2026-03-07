defmodule UniboExPoc.Ofbiz.Party.AgreementTermAttribute do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "party_agreement_term_attributes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_agreement_term_attribute

    queries do
      get :get_party_agreement_term_attribute, :read
      list :list_party_agreement_term_attributes, :read
    end

    mutations do
      create :create_party_agreement_term_attribute, :create
      update :update_party_agreement_term_attribute, :update
      destroy :delete_party_agreement_term_attribute, :destroy
    end

  end

  attributes do
    attribute :agreement_term_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
      description "协议条款编号"
    end
    attribute :attr_name, :string do
      allow_nil? false
      primary_key? true
      public? true
      description "属性名"
    end
    attribute :attr_value, :string do
      public? true
      description "属性值"
    end
    attribute :attr_description, :string do
      public? true
      description "属性说明"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :agreement_term, UniboExPoc.Ofbiz.Party.AgreementTerm do
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
