defmodule UniboExPoc.Ofbiz.Party.CommEventContentAssoc do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_comm_event_content_assocs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_comm_event_content_assoc

    queries do
      get :get_party_comm_event_content_assoc, :read
      list :list_party_comm_event_content_assocs, :read
    end

    mutations do
      create :create_party_comm_event_content_assoc, :create
      update :update_party_comm_event_content_assoc, :update
      destroy :delete_party_comm_event_content_assoc, :destroy
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
    attribute :sequence_num, :integer do
      public? true
      description "序列编号"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :from_content, UniboExPoc.Ofbiz.Party.Content do
      public? true
      source_attribute :content_id
    end
    belongs_to :communication_event, UniboExPoc.Ofbiz.Party.CommunicationEvent do
      public? true
    end
    belongs_to :comm_content_assoc_type, UniboExPoc.Ofbiz.Party.CommContentAssocType do
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
