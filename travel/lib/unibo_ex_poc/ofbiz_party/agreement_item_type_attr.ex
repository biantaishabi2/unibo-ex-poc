defmodule UniboExPoc.Ofbiz.Party.AgreementItemTypeAttr do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "party_agreement_item_type_attrs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_agreement_item_type_attr

    queries do
      get :get_party_agreement_item_type_attr, :read
      list :list_party_agreement_item_type_attrs, :read
    end

    mutations do
      create :create_party_agreement_item_type_attr, :create
      update :update_party_agreement_item_type_attr, :update
      destroy :delete_party_agreement_item_type_attr, :destroy
    end

  end

  attributes do
    attribute :agreement_item_type_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
      description "协议项类型编号"
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
    belongs_to :agreement_item_type, UniboExPoc.Ofbiz.Party.AgreementItemType do
      public? true
      define_attribute? false
    end
    has_many :agreement_item, UniboExPoc.Ofbiz.Party.AgreementItem do
      public? true
      source_attribute :agreement_item_type_id
      destination_attribute :agreement_item_type_id
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
    archive_related [:agreement_item]
  end

end
