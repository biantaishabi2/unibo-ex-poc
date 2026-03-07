defmodule UniboExPoc.Ofbiz.Party.PartyInvitationGroupAssoc do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "party_invitation_group_assocs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_party_invitation_group_assoc

    queries do
      get :get_party_party_invitation_group_assoc, :read
      list :list_party_party_invitation_group_assocs, :read
    end

    mutations do
      create :create_party_party_invitation_group_assoc, :create
      update :update_party_party_invitation_group_assoc, :update
      destroy :delete_party_party_invitation_group_assoc, :destroy
    end

  end

  attributes do
    attribute :party_invitation_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
      description "参与方邀请编号"
    end
    attribute :party_id_to, :uuid do
      allow_nil? false
      primary_key? true
      public? true
      description "参与方编号"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :to_party_group, UniboExPoc.Ofbiz.Party.PartyGroup do
      public? true
      source_attribute :party_id_to
      define_attribute? false
    end
    belongs_to :to_party, UniboExPoc.Ofbiz.Party.Party do
      public? true
      source_attribute :party_id_to
      define_attribute? false
    end
    belongs_to :party_invitation, UniboExPoc.Ofbiz.Party.PartyInvitation do
      public? true
      define_attribute? false
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
