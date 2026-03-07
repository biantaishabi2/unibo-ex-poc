defmodule UniboExPoc.Ofbiz.Party.CommunicationEventProduct do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "party_communication_event_products"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_communication_event_product

    queries do
      get :get_party_communication_event_product, :read
      list :list_party_communication_event_products, :read
    end

    mutations do
      create :create_party_communication_event_product, :create
      update :update_party_communication_event_product, :update
      destroy :delete_party_communication_event_product, :destroy
    end

  end

  attributes do
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product, UniboExPoc.Ofbiz.Party.Product do
      public? true
    end
    belongs_to :communication_event, UniboExPoc.Ofbiz.Party.CommunicationEvent do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
