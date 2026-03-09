defmodule UniboExPoc.Ofbiz.Party.PartyInvitationRoleAssoc do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_invitation_role_assocs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_party_invitation_role_assoc

    queries do
      get :get_party_party_invitation_role_assoc, :read
      list :list_party_party_invitation_role_assocs, :read
    end

    mutations do
      create :create_party_party_invitation_role_assoc, :create
      update :update_party_party_invitation_role_assoc, :update
      destroy :delete_party_party_invitation_role_assoc, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :role_type, UniboExPoc.Ofbiz.Party.RoleType do
      public? true
    end
    belongs_to :party_invitation, UniboExPoc.Ofbiz.Party.PartyInvitation do
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
