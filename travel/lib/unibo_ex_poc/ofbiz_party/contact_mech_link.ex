defmodule UniboExPoc.Ofbiz.Party.ContactMechLink do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_contact_mech_links"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_contact_mech_link

    queries do
      get :get_party_contact_mech_link, :read
      list :list_party_contact_mech_links, :read
    end

    mutations do
      create :create_party_contact_mech_link, :create
      update :update_party_contact_mech_link, :update
      destroy :delete_party_contact_mech_link, :destroy
    end

  end

  attributes do
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :from_contact_mech, UniboExPoc.Ofbiz.Party.ContactMech do
      public? true
      source_attribute :contact_mech_id_from
    end
    belongs_to :to_contact_mech, UniboExPoc.Ofbiz.Party.ContactMech do
      public? true
      source_attribute :contact_mech_id_to
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
