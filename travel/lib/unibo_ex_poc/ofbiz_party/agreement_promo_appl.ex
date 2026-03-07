defmodule UniboExPoc.Ofbiz.Party.AgreementPromoAppl do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "party_agreement_promo_appls"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_agreement_promo_appl

    queries do
      get :get_party_agreement_promo_appl, :read
      list :list_party_agreement_promo_appls, :read
    end

    mutations do
      create :create_party_agreement_promo_appl, :create
      update :update_party_agreement_promo_appl, :update
      destroy :delete_party_agreement_promo_appl, :destroy
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
    attribute :product_promo_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
      description "产品促销编号"
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
    attribute :sequence_num, :integer do
      public? true
      description "序列编号"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_promo, UniboExPoc.Ofbiz.Party.ProductPromo do
      public? true
      define_attribute? false
    end
    belongs_to :agreement, UniboExPoc.Ofbiz.Party.Agreement do
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
