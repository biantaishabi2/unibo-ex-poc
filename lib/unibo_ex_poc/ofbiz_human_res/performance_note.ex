defmodule UniboV4.Ofbiz.HumanRes.PerformanceNote do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.HumanRes,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "human_res_performance_notes"
    repo UniboV4.Repo
  end

  graphql do
    type :human_res_performance_note

    queries do
      get :get_human_res_performance_note, :read
      list :list_human_res_performance_notes, :read
    end

    mutations do
      create :create_human_res_performance_note, :create
      update :update_human_res_performance_note, :update
      destroy :delete_human_res_performance_note, :destroy
    end

  end

  attributes do
    attribute :role_type_id, :string do
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
    attribute :communication_date, :utc_datetime, public?: true
    attribute :comments, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :party, UniboV4.Ofbiz.HumanRes.Party do
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
