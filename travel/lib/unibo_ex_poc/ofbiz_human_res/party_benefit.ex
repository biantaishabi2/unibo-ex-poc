defmodule UniboExPoc.Ofbiz.HumanRes.PartyBenefit do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.HumanRes,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "human_res_party_benefits"
    repo UniboExPoc.Repo
  end

  graphql do
    type :human_res_party_benefit

    queries do
      get :get_human_res_party_benefit, :read
      list :list_human_res_party_benefits, :read
    end

    mutations do
      create :create_human_res_party_benefit, :create
      update :update_human_res_party_benefit, :update
      destroy :delete_human_res_party_benefit, :destroy
    end

  end

  attributes do
    attribute :role_type_id_from, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :role_type_id_to, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :cost, :decimal, public?: true
    attribute :actual_employer_paid_percent, :float, public?: true
    attribute :available_time, :integer, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :to_party, UniboExPoc.Ofbiz.HumanRes.Party do
      public? true
      source_attribute :party_id_to
      attribute_type :string
    end
    belongs_to :from_party, UniboExPoc.Ofbiz.HumanRes.Party do
      public? true
      source_attribute :party_id_from
      attribute_type :string
    end
    belongs_to :benefit_type, UniboExPoc.Ofbiz.HumanRes.BenefitType do
      public? true
      attribute_type :string
    end
    belongs_to :period_type, UniboExPoc.Ofbiz.HumanRes.PeriodType do
      public? true
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
