defmodule UniboExPoc.Ofbiz.Party.ContactMech do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_contact_meches"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_contact_mech

    queries do
      get :get_party_contact_mech, :read
      list :list_party_contact_mechs, :read
    end

    mutations do
      create :create_party_contact_mech, :create
      update :update_party_contact_mech, :update
      destroy :delete_party_contact_mech, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :contact_mech_id, :string do
      public? true
      description "联系方式编号"
    end
    attribute :info_string, :string do
      public? true
      description "信息文本"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :contact_mech_type, UniboExPoc.Ofbiz.Party.ContactMechType do
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
