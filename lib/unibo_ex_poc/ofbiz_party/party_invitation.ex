defmodule UniboExPoc.Ofbiz.Party.PartyInvitation do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_invitations"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_party_invitation

    queries do
      get :get_party_party_invitation, :read
      list :list_party_party_invitations, :read
    end

    mutations do
      create :create_party_party_invitation, :create
      update :update_party_party_invitation, :update
      destroy :delete_party_party_invitation, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :party_invitation_id, :string do
      public? true
      description "参与方邀请编号"
    end
    attribute :party_id, :string do
      public? true
      description "参与方编号"
    end
    attribute :to_name, :string do
      public? true
      description "收件人姓名"
    end
    attribute :email_address, :string do
      public? true
      description "邮箱地址"
    end
    attribute :last_invite_date, :utc_datetime do
      public? true
      description "最近邀请日期"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :party, UniboExPoc.Ofbiz.Party.Party do
      public? true
      source_attribute :party_id_from
    end
    belongs_to :status_item, UniboExPoc.Ofbiz.Party.StatusItem do
      public? true
      source_attribute :status_id
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
