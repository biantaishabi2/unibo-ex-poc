defmodule UniboExPoc.Ofbiz.Party.AgreementContent do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "party_agreement_contents"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_agreement_content

    queries do
      get :get_party_agreement_content, :read
      list :list_party_agreement_contents, :read
    end

    mutations do
      create :create_party_agreement_content, :create
      update :update_party_agreement_content, :update
      destroy :delete_party_agreement_content, :destroy
    end

  end

  attributes do
    attribute :agreement_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
      description "协议编号"
    end
    attribute :agreement_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
      description "协议项序列编号"
    end
    attribute :agreement_content_type_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
      description "协议内容类型编号"
    end
    attribute :content_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
      description "内容编号"
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
      description "来源日期"
    end
    attribute :thru_date, :utc_datetime do
      public? true
      description "到日期"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :agreement, UniboExPoc.Ofbiz.Party.Agreement do
      public? true
      define_attribute? false
    end
    belongs_to :content, UniboExPoc.Ofbiz.Party.Content do
      public? true
      define_attribute? false
    end
    belongs_to :agreement_content_type, UniboExPoc.Ofbiz.Party.AgreementContentType do
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
