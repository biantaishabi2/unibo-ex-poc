defmodule UniboExPoc.Ofbiz.Party.PartyClassification do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_classifications"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_party_classification

    queries do
      get :get_party_party_classification, :read
      list :list_party_party_classifications, :read
    end

    mutations do
      create :create_party_party_classification, :create
      update :update_party_party_classification, :update
      destroy :delete_party_party_classification, :destroy
    end

  end

  attributes do
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
    belongs_to :party, UniboExPoc.Ofbiz.Party.Party do
      public? true
    end
    belongs_to :party_classification_group, UniboExPoc.Ofbiz.Party.PartyClassificationGroup do
      public? true
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
