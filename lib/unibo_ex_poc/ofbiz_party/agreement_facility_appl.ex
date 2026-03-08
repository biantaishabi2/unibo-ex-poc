defmodule UniboV4.Ofbiz.Party.AgreementFacilityAppl do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_agreement_facility_appls"
    repo UniboV4.Repo
  end

  graphql do
    type :party_agreement_facility_appl

    queries do
      get :get_party_agreement_facility_appl, :read
      list :list_party_agreement_facility_appls, :read
    end

    mutations do
      create :create_party_agreement_facility_appl, :create
      update :update_party_agreement_facility_appl, :update
      destroy :delete_party_agreement_facility_appl, :destroy
    end

  end

  attributes do
    attribute :agreement_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
      description "协议项序列编号"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :agreement, UniboV4.Ofbiz.Party.Agreement do
      public? true
    end
    belongs_to :facility, UniboV4.Ofbiz.Party.Facility do
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
