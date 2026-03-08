defmodule UniboV4.Ofbiz.Party.MaritalStatus do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Marital Status."
  end

  postgres do
    table "party_marital_statuses"
    repo UniboV4.Repo
  end

  graphql do
    type :party_marital_status

    queries do
      get :get_party_marital_status, :read
      list :list_party_marital_statuss, :read
    end

    mutations do
      create :create_party_marital_status, :create
      update :update_party_marital_status, :update
      destroy :delete_party_marital_status, :destroy
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
    belongs_to :party, UniboV4.Ofbiz.Party.Party do
      public? true
    end
    belongs_to :marital_status_type, UniboV4.Ofbiz.Party.MaritalStatusType do
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
