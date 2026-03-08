defmodule UniboV4.Ofbiz.Party.PartyIdentification do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_identifications"
    repo UniboV4.Repo
  end

  graphql do
    type :party_party_identification

    queries do
      get :get_party_party_identification, :read
      list :list_party_party_identifications, :read
    end

    mutations do
      create :create_party_party_identification, :create
      update :update_party_party_identification, :update
      destroy :delete_party_party_identification, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :id_value, :string do
      public? true
      description "编号值"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :party_identification_type, UniboV4.Ofbiz.Party.PartyIdentificationType do
      public? true
    end
    belongs_to :party, UniboV4.Ofbiz.Party.Party do
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
