defmodule UniboExPoc.Ofbiz.Party.PartyContent do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "party_contents"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_party_content

    queries do
      get :get_party_party_content, :read
      list :list_party_party_contents, :read
    end

    mutations do
      create :create_party_party_content, :create
      update :update_party_party_content, :update
      destroy :delete_party_party_content, :destroy
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
    belongs_to :content, UniboExPoc.Ofbiz.Party.Content do
      public? true
    end
    belongs_to :party_content_type, UniboExPoc.Ofbiz.Party.PartyContentType do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
