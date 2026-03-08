defmodule UniboV4.Ofbiz.Party.ValidContactMechRole do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_valid_contact_mech_roles"
    repo UniboV4.Repo
  end

  graphql do
    type :party_valid_contact_mech_role

    queries do
      get :get_party_valid_contact_mech_role, :read
      list :list_party_valid_contact_mech_roles, :read
    end

    mutations do
      create :create_party_valid_contact_mech_role, :create
      update :update_party_valid_contact_mech_role, :update
      destroy :delete_party_valid_contact_mech_role, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :role_type, UniboV4.Ofbiz.Party.RoleType do
      public? true
    end
    belongs_to :contact_mech_type, UniboV4.Ofbiz.Party.ContactMechType do
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
