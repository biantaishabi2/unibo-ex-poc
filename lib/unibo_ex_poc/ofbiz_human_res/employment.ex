defmodule UniboExPoc.Ofbiz.HumanRes.Employment do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.HumanRes,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "human_res_employments"
    repo UniboExPoc.Repo
  end

  graphql do
    type :human_res_employment

    queries do
      get :get_human_res_employment, :read
      list :list_human_res_employments, :read
    end

    mutations do
      create :create_human_res_employment, :create
      update :update_human_res_employment, :update
      destroy :delete_human_res_employment, :destroy
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
    belongs_to :termination_reason, UniboExPoc.Ofbiz.HumanRes.TerminationReason do
      public? true
      attribute_type :string
    end
    belongs_to :termination_type, UniboExPoc.Ofbiz.HumanRes.TerminationType do
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
