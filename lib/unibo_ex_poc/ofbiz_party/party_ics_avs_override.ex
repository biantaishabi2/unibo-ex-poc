defmodule UniboExPoc.Ofbiz.Party.PartyIcsAvsOverride do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_ics_avs_overrides"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_party_ics_avs_override

    queries do
      get :get_party_party_ics_avs_override, :read
      list :list_party_party_ics_avs_overrides, :read
    end

    mutations do
      create :create_party_party_ics_avs_override, :create
      update :update_party_party_ics_avs_override, :update
      destroy :delete_party_party_ics_avs_override, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :avs_decline_string, :string do
      public? true
      description "AVS拒绝字符串"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :party, UniboExPoc.Ofbiz.Party.Party do
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
