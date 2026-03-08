defmodule UniboV4.Ofbiz.Party.AgreementEmploymentAppl do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "party_agreement_employment_appls"
    repo UniboV4.Repo
  end

  graphql do
    type :party_agreement_employment_appl

    queries do
      get :get_party_agreement_employment_appl, :read
      list :list_party_agreement_employment_appls, :read
    end

    mutations do
      create :create_party_agreement_employment_appl, :create
      update :update_party_agreement_employment_appl, :update
      destroy :delete_party_agreement_employment_appl, :destroy
    end

  end

  attributes do
    attribute :agreement_id, :string do
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
    attribute :party_id_from, :string do
      allow_nil? false
      primary_key? true
      public? true
      description "参与方编号来源"
    end
    attribute :party_id_to, :string do
      allow_nil? false
      primary_key? true
      public? true
      description "参与方编号"
    end
    attribute :role_type_id_from, :string do
      allow_nil? false
      primary_key? true
      public? true
      description "角色类型编号来源"
    end
    attribute :role_type_id_to, :string do
      allow_nil? false
      primary_key? true
      public? true
      description "角色类型编号"
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
      description "来源日期"
    end
    attribute :agreement_date, :utc_datetime do
      public? true
      description "协议日期"
    end
    attribute :thru_date, :utc_datetime do
      public? true
      description "到日期"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
