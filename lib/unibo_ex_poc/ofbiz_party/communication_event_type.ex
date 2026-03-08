defmodule UniboV4.Ofbiz.Party.CommunicationEventType do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_communication_event_types"
    repo UniboV4.Repo
  end

  graphql do
    type :party_communication_event_type

    queries do
      get :get_party_communication_event_type, :read
      list :list_party_communication_event_types, :read
    end

    mutations do
      create :create_party_communication_event_type, :create
      update :update_party_communication_event_type, :update
      destroy :delete_party_communication_event_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :communication_event_type_id, :string do
      public? true
      description "沟通活动类型编号"
    end
    attribute :has_table, :boolean do
      public? true
      description "有表"
    end
    attribute :description, :string do
      public? true
      description "说明"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_communication_event_type, UniboV4.Ofbiz.Party.CommunicationEventType do
      public? true
      source_attribute :parent_type_id
    end
    belongs_to :contac_mech_type_contact_mech_type, UniboV4.Ofbiz.Party.ContactMechType do
      public? true
      source_attribute :contact_mech_type_id
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
