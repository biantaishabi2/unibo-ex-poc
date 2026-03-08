defmodule UniboExPoc.Ofbiz.Party.ContactMechTypePurpose do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "定义哪些联系方式用途类型适用于哪些联系方式类型"
  end

  postgres do
    table "party_contact_mech_type_purposes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_contact_mech_type_purpose

    queries do
      get :get_party_contact_mech_type_purpose, :read
      list :list_party_contact_mech_type_purposes, :read
    end

    mutations do
      create :create_party_contact_mech_type_purpose, :create
      update :update_party_contact_mech_type_purpose, :update
      destroy :delete_party_contact_mech_type_purpose, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :contact_mech_type, UniboExPoc.Ofbiz.Party.ContactMechType do
      public? true
    end
    belongs_to :contact_mech_purpose_type, UniboExPoc.Ofbiz.Party.ContactMechPurposeType do
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
