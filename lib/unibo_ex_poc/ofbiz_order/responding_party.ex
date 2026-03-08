defmodule UniboV4.Ofbiz.Order.RespondingParty do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_responding_parties"
    repo UniboV4.Repo
  end

  graphql do
    type :order_responding_party

    queries do
      get :get_order_responding_party, :read
      list :list_order_responding_partys, :read
    end

    mutations do
      create :create_order_responding_party, :create
      update :update_order_responding_party, :update
      destroy :delete_order_responding_party, :destroy
    end

  end

  attributes do
    attribute :responding_party_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :contact_mech_id, :string, public?: true
    attribute :date_sent, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :cust_request, UniboV4.Ofbiz.Order.CustRequest do
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
