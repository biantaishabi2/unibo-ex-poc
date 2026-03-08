defmodule UniboV4.Ofbiz.Party.AgreementContent do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "party_agreement_contents"
    repo UniboV4.Repo
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
    attribute :agreement_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
      description "协议项序列编号"
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
    belongs_to :agreement, UniboV4.Ofbiz.Party.Agreement do
      public? true
    end
    belongs_to :content, UniboV4.Ofbiz.Party.Content do
      public? true
    end
    belongs_to :agreement_content_type, UniboV4.Ofbiz.Party.AgreementContentType do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
