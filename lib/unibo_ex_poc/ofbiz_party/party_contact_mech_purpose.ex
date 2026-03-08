defmodule UniboV4.Ofbiz.Party.PartyContactMechPurpose do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_contact_mech_purposes"
    repo UniboV4.Repo
  end

  graphql do
    type :party_party_contact_mech_purpose

    queries do
      get :get_party_party_contact_mech_purpose, :read
      list :list_party_party_contact_mech_purposes, :read
    end

    mutations do
      create :create_party_party_contact_mech_purpose, :create
      update :update_party_party_contact_mech_purpose, :update
      destroy :delete_party_party_contact_mech_purpose, :destroy
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
    belongs_to :contact_mech_purpose_type, UniboV4.Ofbiz.Party.ContactMechPurposeType do
      public? true
    end
    belongs_to :party, UniboV4.Ofbiz.Party.Party do
      public? true
    end
    belongs_to :person, UniboV4.Ofbiz.Party.Person do
      public? true
      source_attribute :party_id
      define_attribute? false
    end
    belongs_to :party_group, UniboV4.Ofbiz.Party.PartyGroup do
      public? true
      source_attribute :party_id
      define_attribute? false
    end
    belongs_to :contact_mech, UniboV4.Ofbiz.Party.ContactMech do
      public? true
    end
    belongs_to :postal_address, UniboV4.Ofbiz.Party.PostalAddress do
      public? true
      source_attribute :contact_mech_id
      define_attribute? false
    end
    belongs_to :telecom_number, UniboV4.Ofbiz.Party.TelecomNumber do
      public? true
      source_attribute :contact_mech_id
      define_attribute? false
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
