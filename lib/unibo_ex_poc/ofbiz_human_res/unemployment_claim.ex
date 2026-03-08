defmodule UniboV4.Ofbiz.HumanRes.UnemploymentClaim do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.HumanRes,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "human_res_unemployment_claims"
    repo UniboV4.Repo
  end

  graphql do
    type :human_res_unemployment_claim

    queries do
      get :get_human_res_unemployment_claim, :read
      list :list_human_res_unemployment_claims, :read
    end

    mutations do
      create :create_human_res_unemployment_claim, :create
      update :update_human_res_unemployment_claim, :update
      destroy :delete_human_res_unemployment_claim, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :unemployment_claim_id, :string, public?: true
    attribute :unemployment_claim_date, :utc_datetime, public?: true
    attribute :description, :string, public?: true
    attribute :party_id_from, :string, public?: true
    attribute :party_id_to, :string, public?: true
    attribute :role_type_id_from, :string, public?: true
    attribute :role_type_id_to, :string, public?: true
    attribute :from_date, :utc_datetime, public?: true
    attribute :thru_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :status_item, UniboV4.Ofbiz.HumanRes.StatusItem do
      public? true
      source_attribute :status_id
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
