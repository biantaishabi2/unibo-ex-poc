defmodule UniboExPoc.Ofbiz.Party.CommunicationEventPurpose do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "party_communication_event_purposes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_communication_event_purpose

    queries do
      get :get_party_communication_event_purpose, :read
      list :list_party_communication_event_purposes, :read
    end

    mutations do
      create :create_party_communication_event_purpose, :create
      update :update_party_communication_event_purpose, :update
      destroy :delete_party_communication_event_purpose, :destroy
    end

  end

  attributes do
    attribute :communication_event_prp_typ_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
      description "通信事件目的类型编号"
    end
    attribute :communication_event_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
      description "沟通活动编号"
    end
    attribute :description, :string do
      public? true
      description "说明"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :communication_event, UniboExPoc.Ofbiz.Party.CommunicationEvent do
      public? true
      define_attribute? false
    end
    belongs_to :communication_event_prp_typ, UniboExPoc.Ofbiz.Party.CommunicationEventPrpTyp do
      public? true
      define_attribute? false
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
